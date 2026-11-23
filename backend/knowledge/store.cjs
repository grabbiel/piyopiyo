'use strict';
const {DynamoDBClient}=require('@aws-sdk/client-dynamodb');const {DynamoDBDocumentClient,GetCommand,PutCommand,UpdateCommand,QueryCommand}=require('@aws-sdk/lib-dynamodb');
const {S3Client,GetObjectCommand,PutObjectCommand}=require('@aws-sdk/client-s3');const {SQSClient,SendMessageCommand}=require('@aws-sdk/client-sqs');
const config={region:process.env.AWS_REGION||'us-east-1',maxAttempts:3};const db=DynamoDBDocumentClient.from(new DynamoDBClient(config),{marshallOptions:{removeUndefinedValues:true}}),s3=new S3Client(config),sqs=new SQSClient(config);const TableName=process.env.KNOWLEDGE_TABLE,Bucket=process.env.KNOWLEDGE_BUCKET;
const get=async(PK,SK)=>(await db.send(new GetCommand({TableName,Key:{PK,SK},ConsistentRead:true}))).Item;
const put=async item=>db.send(new PutCommand({TableName,Item:item}));
async function list(PK,limit=100){let cursor,all=[];do{const r=await db.send(new QueryCommand({TableName,KeyConditionExpression:'PK = :pk',ExpressionAttributeValues:{':pk':PK},ExclusiveStartKey:cursor,Limit:Math.min(100,limit-all.length),ScanIndexForward:false}));all.push(...r.Items||[]);cursor=r.LastEvaluatedKey;}while(cursor&&all.length<limit);return all;}
async function read(key,bucket=Bucket){const r=await s3.send(new GetObjectCommand({Bucket:bucket,Key:key}));return {data:await r.Body.transformToByteArray(),etag:r.ETag};}
async function readJSON(key,bucket=Bucket,fallback){try{const r=await read(key,bucket);return {...r,value:JSON.parse(Buffer.from(r.data).toString())};}catch(e){if(fallback!==undefined&&['NoSuchKey','NotFound'].includes(e.name))return {value:fallback};throw e;}}
const write=async(key,value,type='application/json',bucket=Bucket,extra={})=>s3.send(new PutObjectCommand({Bucket:bucket,Key:key,Body:typeof value==='string'||Buffer.isBuffer(value)?value:JSON.stringify(value),ContentType:type,...extra}));
const enqueue=async body=>sqs.send(new SendMessageCommand({QueueUrl:process.env.KNOWLEDGE_QUEUE,MessageGroupId:'pipeline',MessageBody:JSON.stringify(body)}));
const settings=async()=>({...{enabled:true,autoPublish:true,maxModelCalls:60},...await get('CONFIG','pipeline')});
module.exports={db,s3,TableName,Bucket,get,put,list,read,readJSON,write,enqueue,settings,UpdateCommand,PutCommand};
