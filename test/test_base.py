#!/usr/bin/env python3

from seleniumbase import BaseCase

import os
import re
import time

BASE = os.environ.get("GEONODE_URL", "http://127.0.0.1:8080")
GEOTIFF = os.path.abspath("data/ntf_nord.tif")
USER = os.environ.get("GEONODE_USER", "super")
PASS = os.environ.get("GEONODE_PASS", "duper")
DOMAIN = os.environ.get("GEONODE_DOMAIN", "example.com")

FILENAME = os.path.split(GEOTIFF)[-1]
LAYERNAME = os.path.splitext(FILENAME)[0]


class LayerUploadCheck(BaseCase):

    def click_button(self, label):
        selector = "//button[contains(., '%s')]" % label
        self.driver.find_element_by_xpath(selector).click()

    def superuser(func):
        def wrapper(self, *args, **kwargs):
            self.open(BASE+"/account/login/?next=/")
            self.update_text("#id_login", USER)
            self.update_text("#id_password", PASS)
            self.click_button("Sign In")
            func(self, *args, **kwargs)
            self.open(BASE+"/account/logout/?next=/")
            self.click_button("Log out")
        return wrapper

    @superuser
    def test_login(self):
        pass

    @superuser
    def upload(self):
        self.click_link("Data")
        self.click_link("Layers")
        self.click_link("Upload Layers")
        self.execute_script("jQuery('#file-input').show()")
        self.update_text('#file-input', GEOTIFF)
        self.click_link("Upload files")
        self.click_link("Layer Info", timeout=90)

    @superuser
    def remove(self):
        self.click_link("Data")
        self.click_link("Layers")
        self.click_link(LAYERNAME, timeout=30)
        # Workaround for non-SPCGeonode
        self.open(BASE+"/layers/geonode:%s" % LAYERNAME)
        self.click_button("Editing Tools")
        self.click_link("Remove")
        self.click('input[value="Yes, I am sure"]', timeout=90)
        for _i in range(10):
            if "Explore Layers" in self.get_title():
                break
            time.sleep(10)
        self.assertTrue("Explore Layers" in self.get_title())
        # src = self.driver.page_source
        # text_found = re.search(r'0 Layers found', src)
        # self.assertNotEqual(text_found, None)

    def layer(func):
        def wrapper(self, *args, **kwargs):
            self.upload()
            func(self, *args, **kwargs)
            self.remove()
        return wrapper

    @layer
    def test_upload(self):
        pass

    @layer
    def test_preview(self):
        self.open(BASE+'/geoserver')
        self.click_link("Layer Preview")
        self.click_link("OpenLayers")
        self.switch_to_window(1)
        self.assertEqual("OpenLayers map preview", self.get_title())
        self.driver.close()
        self.switch_to_default_window()
        self.open(BASE)

    @layer
    def test_missing_thumbnail(self):
        self.open(BASE+'/layers/')
        elements = self.driver.find_elements_by_xpath(
            "//img[contains(@src, 'missing_thumb.png')]"
        )
        self.assertEqual(len(elements), 0)

    @layer
    def test_broken_thumbnail(self):
        self.open(BASE+'/layers/')
        for img in self.find_elements('img'):
            src = img.get_attribute('src')
            # Skip external images
            if not src.startswith(BASE):
                continue
            status_code = self.get_link_status_code(src)
            self.assertEqual(status_code, 200)

    @layer
    def test_layer_no_errors(self):
        self.assert_no_404_errors()
        self.assert_no_js_errors()

    @layer
    def test_layers_no_errors(self):
        self.open(BASE+'/layers/')
        self.assert_no_404_errors()
        self.assert_no_js_errors()

    def test_home_no_errors(self):
        self.assert_no_404_errors()
        self.assert_no_js_errors()

    @superuser
    def test_home_no_404_admin(self):
        self.assert_no_404_errors()
        self.assert_no_js_errors()
