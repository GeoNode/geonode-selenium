#!/usr/bin/env python3

from seleniumbase import BaseCase
import os

BASE = "http://127.0.0.1"
GEOTIFF = os.path.abspath("data/UTM2GTIF.TIF")
USER = "super"
PASS = "duper"

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
        self.click_link("Layers")
        self.click_link("Upload Layers")
        self.execute_script("jQuery('#file-input').show()")
        self.update_text('#file-input', GEOTIFF)
        self.click_link("Upload files")
        self.click_link("Layer Info", timeout=60)

    @superuser
    def remove(self):
        self.click_link("Layers")
        self.click_link('utm2gtif')
        self.click_button("Editing Tools")
        self.click_link("Remove")
        self.click('input[value="Yes, I am sure"]')
        self.assertEqual("Explore Layers - example.com", self.get_title())

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
