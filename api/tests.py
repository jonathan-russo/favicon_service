from django.test import TestCase
from django.test.client import RequestFactory
import api.favicon
import base64
import json

# Create your tests here.
class ApiTestCase(TestCase):

  def test_valid_uri_input(self):
    """ Test a valid uri input """
    scheme, domain = api.favicon.validate_uri("https:duckduckgo.com")
    self.assertEqual(scheme, "https")
    self.assertEqual(domain, "duckduckgo.com")

  def test_invalid_uri_input(self):
    """ Test various invalid uri inputs """
    cases = [
      "tcp:duckduckgo.com",
      "duckduckgo.com",
      "duckduckgo.com:https",
      "fhdafjdsafkjsd"
    ]
    for case in cases:
      with self.assertRaises(ValueError):
        api.favicon.validate_uri(case)
    
  def test_default_image(self):
    """ Tests that a valid default image is returned """
    content_type, img_object = api.favicon.get_default_icon()
    self.assertIn("image/", content_type)
    self.assertEqual(type(img_object), bytes)

  def test_proper_error_resp(self):
    """ Tests that an error response is properly returned """
    status_code = 400
    title = "Failure"
    detail = "Detailed Failure Message"
    expected_dict = {
      "errors": [
        {
            "status" : status_code,
            "title"  : title,
            "detail" : detail
        }
      ]}
    
    self.assertEqual(expected_dict, api.favicon.format_error_response(status_code,title, detail))

  def test_valid_non_default_icon_returned(self):
    """ Test that valid, non default icon is returned """
    default_content_type, default_img_object = api.favicon.get_default_icon()
    content_type, img_object = api.favicon.get_favicon("https://google.com")

    base64_default_icon = base64.b64encode(default_img_object).decode('utf-8')
    base64_non_default_icon = base64.b64encode(img_object).decode('utf-8')

    self.assertNotEqual(base64_default_icon, base64_non_default_icon)

  def test_success_json_response(self):
    """ Test proper json response is returned """
    request = RequestFactory().get("/favicon/https:duckduckgo.com/")

    response = api.favicon.serve_favicon_req(request, "https:duckduckgo.com")

    self.assertEqual(response.status_code, 200)

    responseDict= json.loads(response.content.decode('utf-8'))
    self.assertTrue("data" in responseDict.keys())
    for obj in responseDict['data']:
      for requiredField in ["scheme", "domain", "data_url"]:
        self.assertTrue(requiredField in obj)
    
