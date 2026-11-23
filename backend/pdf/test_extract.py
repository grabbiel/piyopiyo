import importlib.util
import io
import os
import pathlib
import unittest
os.environ.update(AWS_EC2_METADATA_DISABLED="true", AWS_DEFAULT_REGION="us-east-1", AWS_ACCESS_KEY_ID="test", AWS_SECRET_ACCESS_KEY="test")
from pypdf import PdfWriter
from pypdf.generic import DictionaryObject, NameObject, DecodedStreamObject
spec = importlib.util.spec_from_file_location("extractor", pathlib.Path(__file__).with_name("index.py"))
extractor = importlib.util.module_from_spec(spec)
spec.loader.exec_module(extractor)

def fixture():
    writer = PdfWriter()
    page = writer.add_blank_page(width=612, height=792)
    font = DictionaryObject({NameObject("/Type"): NameObject("/Font"), NameObject("/Subtype"): NameObject("/Type1"), NameObject("/BaseFont"): NameObject("/Helvetica")})
    page[NameObject("/Resources")] = DictionaryObject({NameObject("/Font"): DictionaryObject({NameObject("/F1"): writer._add_object(font)})})
    lines = ["PiyoPiyo original learning notes: queues and stacks", "A queue follows first-in-first-out order. Items enter at the tail and leave at the head.", "Enqueuing A, then B, then C means dequeuing returns A, then B, then C.", "A stack follows last-in-first-out order. Push adds at the top; pop removes the top.", "Pushing A, then B, then C means popping returns C, then B, then A.", "A linked queue with both head and tail pointers supports constant-time enqueue", "and dequeue. A stack implemented with a linked list supports constant-time push", "and pop at the head. The abstract ordering rule does not prescribe storage layout.", "A bounded queue has a fixed capacity. A full queue must reject, wait, or apply an", "explicit overflow policy; silently overwriting data is not part of the queue contract.", "A circular buffer reuses freed slots by wrapping indices modulo its capacity.", "A breadth-first graph traversal uses a queue for its frontier. A depth-first traversal", "can use a stack. Marking visited vertices prevents repeated processing in cycles."]
    stream = DecodedStreamObject(); stream.set_data(("BT /F1 11 Tf 42 740 Td 17 TL " + " ".join("(" + line + ") Tj T*" for line in lines) + " ET").encode())
    page[NameObject("/Contents")] = writer._add_object(stream)
    output = io.BytesIO(); writer.write(output); return output.getvalue()

class ExtractionTests(unittest.TestCase):
    def test_searchable_pdf_and_page_numbers(self):
        pages = extractor.extract(fixture())
        self.assertEqual(pages[0]["page"], 1)
        self.assertIn("first-in-first-out", pages[0]["text"])
    def test_encrypted_and_empty_documents_fail_clearly(self):
        writer = PdfWriter(); writer.add_blank_page(width=100, height=100)
        output = io.BytesIO(); writer.write(output)
        with self.assertRaisesRegex(ValueError, "OCR"): extractor.extract(output.getvalue())
        writer.encrypt("private"); output = io.BytesIO(); writer.write(output)
        with self.assertRaisesRegex(ValueError, "Password"): extractor.extract(output.getvalue())
    def test_wrong_format_rejected(self):
        with self.assertRaises(ValueError): extractor.extract(b"not a pdf")

if __name__ == "__main__":
    target = pathlib.Path("tests/fixtures/knowledge-notes.pdf"); target.parent.mkdir(parents=True, exist_ok=True); target.write_bytes(fixture())
    unittest.main()
