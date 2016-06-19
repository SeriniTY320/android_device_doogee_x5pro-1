# Release name
PRODUCT_RELEASE_NAME := x5pro

# Inherit some common CM stuff.
$(call inherit-product, vendor/cm/config/common_full_phone.mk)

# Inherit device configuration
$(call inherit-product, device/doogee/x5pro/device_x5pro.mk)

# Configure dalvik heap
$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)


TARGET_SCREEN_HEIGHT := 1280	
TARGET_SCREEN_WIDTH := 720

# Device identifier. This must come after all inclusions
PRODUCT_DEVICE := x5pro
PRODUCT_NAME := cm_x5pro
PRODUCT_BRAND := ark
PRODUCT_MODEL := x5pro
PRODUCT_MANUFACTURER := doogee

PRODUCT_DEFAULT_LANGUAGE := ru
PRODUCT_DEFAULT_REGION   := RU
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.timezone=Europe/Moscow
