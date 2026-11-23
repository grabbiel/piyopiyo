"""Write only public app endpoints/IDs from the verified PiyoPiyo development stack."""
import json,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[1]
identity=json.loads(subprocess.check_output([str(root/'scripts/aws.sh'),'sts','get-caller-identity'],text=True))
assert identity['Account']=='992680757326' and ':root' not in identity['Arn']
result=json.loads(subprocess.check_output([str(root/'scripts/aws.sh'),'cloudformation','describe-stacks','--stack-name','PiyoPiyoDev'],text=True))
outputs={x['OutputKey']:x['OutputValue'] for x in result['Stacks'][0]['Outputs']}
keys=['ApiUrl','UserPoolId','ClientId','IdentityPoolId','AuthDomain','LiveUrl','Region','TableName']
(root/'PiyoPiyo/PiyoPiyoCore/Sources/PiyoPiyoCore/Resources/configuration.json').write_text(json.dumps({k:outputs[k] for k in keys},indent=2)+'\n')
(root/'.agent/stack.json').write_text(json.dumps(result,indent=2)+'\n')
print('Updated public client configuration from PiyoPiyoDev')
