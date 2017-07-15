# PespectiveCorrectionView
subclass of UIView with ability of perspective correction

# Overview

before:

<img src="https://github.com/kenny1269/PespectiveCorrectionView/blob/master/screenshot/before.jpg" height="500" />


after:

<img src="https://github.com/kenny1269/PespectiveCorrectionView/blob/master/screenshot/after.jpg" height="500" />

# Usage

Easy to use. 
1. Import `KYPerspectiveCorrectionView.h`, layout just as a normal UIView.
2. Set the image you want to do perspective correction using instance method `setImage:`.
3. Tap and draw the control points to the vertexes of the rectangle.
4. Use instance method `perspectiveCorrection` to get the result UIImage.
5. You can also enable the rectangle detection by setting the property `enableRectangleDetection` to YES.
