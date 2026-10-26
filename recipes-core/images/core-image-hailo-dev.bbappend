# No display on this product: the DSI test tools stay out of the image.
IMAGE_INSTALL:remove = "sysele-dsi-detection sysele-dsi-touch-test"

# swupdate in the running system, as run_swupdate.sh uses it in dual (A/B) mode and for dry runs, verifies
# against this key.
IMAGE_INSTALL:append = " swupdate-public-key"
