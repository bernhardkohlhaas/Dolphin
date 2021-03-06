"Filed out from Dolphin Smalltalk 7"!

GdiplusBrush subclass: #GdiplusPathGradientBrush
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
GdiplusPathGradientBrush guid: (GUID fromString: '{c8f38622-766b-11d7-b609-00e0987e8081}')!
GdiplusPathGradientBrush comment: 'A path gradient brush paints a color gradient in which the color changes from a center point outward to a boundary that is defined by a closed curve or path. The color gradient has one color at the center point and one or multiple colors at the boundary. '!
!GdiplusPathGradientBrush categoriesForClass!Unclassified! !
!GdiplusPathGradientBrush methodsFor!

blendBellShape: focusReal scale: scaleReal 
	| status |
	(status := GdiplusLibrary default 
				gdipSetPathGradientSigmaBlend: self asParameter
				focus: focusReal
				scale: scaleReal) = Ok 
		ifFalse: [GdiplusError signal: 'GdipSetPathGradientSigmaBlend failed' with: status]!

blendColors
	| status count blend positions |
	count := self blendColorsCount.
	blend := DWORDArray new: count.
	positions := FLOATArray new: count.
	(status := GdiplusLibrary default
				gdipGetPathGradientPresetBlend: self asParameter
				blend: blend
				positions: positions
				count: count) = Ok
		ifFalse: [GdiplusError signal: 'GdipGetPathGradientPresetBlend failed' with: status].
	^Array with: (blend asArray collect: [:e | ARGB fromInteger: e]) with: positions asArray!

blendColors: colorsArray positions: positionsArray 
	"Set the preset colors and the blend positions of this path gradient brush.  colorsArray
	specifies the interpolation colors for the gradient. Each color in colorsArray 
	corresponds to a blend position in positionsArray.  Each blend position is a number from
	 0 through 1, where 0 indicates the boundary of the gradient and 1 indicates the center point. 
	A blend position between 0 and 1 specifies the set of all points that are a certain fraction of 
	the distance from the boundary to the center point. For example, a blend position of 0.7 
	specifies the set of all points that are 70 percent of the way from the boundary to the center point."

	| status |
	self assert: [colorsArray size = positionsArray size].
	self assert: [positionsArray size >= 2].
	self assert: [positionsArray first = 0 and: [positionsArray last = 1]].
	(status := GdiplusLibrary default 
				gdipSetPathGradientPresetBlend: self asParameter
				blend: (DWORDArray withAll: (colorsArray collect: [:e | e asParameter]))
				positions: (FLOATArray withAll: positionsArray)
				count: colorsArray size) = Ok 
		ifFalse: [GdiplusError signal: 'GdipSetPathGradientPresetBlend failed' with: status]!

blendColorsCount
	"Answer the <Integer> number of preset colors currently set for the receiver."

	| status count |
	count := SDWORD new.
	(status := GdiplusLibrary default gdipGetPathGradientPresetBlendCount: self asParameter count: count)
		= Ok ifFalse: [GdiplusError signal: 'GdipGetPathGradientPresetBlendCount failed' with: status].
	^count value!

blendFactors
	| status count factors positions |
	count := self blendFactorsCount.
	factors := FLOATArray new: count.
	positions := FLOATArray new: count.
	(status := GdiplusLibrary default
				gdipGetPathGradientBlend: self asParameter
				blend: factors
				positions: positions
				count: count) = Ok
		ifFalse: [GdiplusError signal: 'GdipGetPathGradientBlend failed' with: status].
	^Array with: factors asArray with: positions asArray!

blendFactors: factorsArray positions: positionsArray 
	| status |
	self assert: [factorsArray size = positionsArray size].
	self assert: [positionsArray size >= 2].
	self assert: [factorsArray allSatisfy: [:each | each between: 0 and: 1]].
	self assert: [positionsArray first = 0 and: [positionsArray last = 1]].
	(status := GdiplusLibrary default 
				gdipSetPathGradientBlend: self asParameter
				blend: (FLOATArray withAll: factorsArray)
				positions: (FLOATArray withAll: positionsArray)
				count: factorsArray size) = Ok 
		ifFalse: [GdiplusError signal: 'GdipSetPathGradientBlend failed' with: status]!

blendFactorsCount
	"Answer the <Integer> number of blend factors currently set for the receiver."

	| status count |
	count := SDWORD new.
	(status := GdiplusLibrary default gdipGetPathGradientBlendCount: self asParameter count: count) = Ok
		ifFalse: [GdiplusError signal: 'GdipGetPathGradientBlendCount failed' with: status].
	^count value!

blendTriangularShape: focusReal scale: scaleReal 
	| status |
	(status := GdiplusLibrary default 
				gdipSetPathGradientLinearBlend: self asParameter
				focus: focusReal
				scale: scaleReal) = Ok 
		ifFalse: [GdiplusError signal: 'GdipSetPathGradientLinearBlend failed' with: status]!

bounds
	"Answer a bounding Rectangle for the receiver."

	| status rect |
	rect := RECTL new.
	(status := GdiplusLibrary default gdipGetPathGradientRectI: self asParameter rect: rect) = Ok
		ifFalse: [GdiplusError signal: 'GdipGetPathGradientRectI failed' with: status].
	^rect asRectangle!

centerColor
	"Answer the ARGB color that appears at the receiver's center point."

	| status color |
	color := DWORD new.
	(status := GdiplusLibrary default gdipGetPathGradientCenterColor: self asParameter colors: color)
		= Ok ifFalse: [GdiplusError signal: 'GdipGetPathGradientCenterColor failed' with: status].
	^ARGB fromInteger: color value!

centerColor: anARGB 
	"Set the color that appears at the receiver's center point."

	| status |
	(status := GdiplusLibrary default gdipSetPathGradientCenterColor: self asParameter
				colors: anARGB asParameter) = Ok 
		ifFalse: [GdiplusError signal: 'GdipSetPathGradientCenterColor failed' with: status]!

centerPoint
	"Answer the center point of the receiver."

	| status point |
	point := POINT new.
	(status := GdiplusLibrary default gdipGetPathGradientCenterPointI: self asParameter points: point)
		= Ok ifFalse: [GdiplusError signal: 'GdipGetPathGradientCenterPointI failed' with: status].
	^point asPoint!

centerPoint: aPoint 
	"Set the center point of the receiver. By default, the center point is at the centroid of the 
	receiver's boundary path, but it can be set to any location inside or outside the path."

	| status |
	(status := GdiplusLibrary default gdipSetPathGradientCenterPointI: self asParameter
				points: (POINTL fromPoint: aPoint)) = Ok 
		ifFalse: [GdiplusError signal: 'GdipSetPathGradientCenterPointI failed' with: status]!

focusScales
	"Answer a Point that represents the x and y scale factors for the receiver's center color relative to its boundary path."

	| status x y |
	x := FLOAT new.
	y := FLOAT new.
	(status := GdiplusLibrary default
				gdipGetPathGradientFocusScales: self asParameter
				xScale: x
				yScale: y) = Ok
		ifFalse: [GdiplusError signal: 'GdipGetPathGradientFocusScales failed' with: status].
	^x value @ y value!

focusScales: aPoint 
	"Specify that the receiver's center color should appear within the receiver's boundary path 
	scaled by a factor of aPoint in the x and y directions."

	| status |
	(status := GdiplusLibrary default 
				gdipSetPathGradientFocusScales: self asParameter
				xScale: aPoint x
				yScale: aPoint y) = Ok 
		ifFalse: [GdiplusError signal: 'GdipSetPathGradientFocusScales failed' with: status]!

isGammaCorrected
	"Answer whether or not gamma correction is applied to the receiver."

	| status result |
	result := SDWORD new.
	(status := GdiplusLibrary default gdipGetPathGradientGammaCorrection: self asParameter
				useGammaCorrection: result asParameter) = Ok 
		ifFalse: [GdiplusError signal: 'GdipGetPathGradientGammaCorrection failed' with: status].
	^result ~= 0!

isGammaCorrected: aBoolean 
	"Set whether or not gamma correction should be applied to the receiver."

	| status |
	(status := GdiplusLibrary default gdipSetPathGradientGammaCorrection: self asParameter
				useGammaCorrection: aBoolean asParameter) = Ok 
		ifFalse: [GdiplusError signal: 'GdipSetPathGradientGammaCorrection failed' with: status]!

multiplyTransform: aGdiplusMatrix 
	"Set the receiver's transformation matrix to the product of itself and aGdiplusMatrix."

	self multiplyTransform: aGdiplusMatrix order: nil!

multiplyTransform: aGdiplusMatrix order: aMatrixOrderConstant 
	"Set the receiver's transformation matrix to the product of itself and aGdiplusMatrix
	with the order of transformation specified by aMatrixOrderConstant."

	| status |
	(status := GdiplusLibrary default 
				gdipMultiplyPathGradientTransform: self asParameter
				matrix: aGdiplusMatrix asParameter
				order: aMatrixOrderConstant) = Ok 
		ifFalse: [GdiplusError signal: 'GdipMultiplyPathGradientTransform failed' with: status]!

pointCount
	"Private - Answer the number of points that define the receiver's boundary path."

	| status count |
	count := SDWORD new.
	(status := GdiplusLibrary default gdipGetPathGradientPointCount: self asParameter count: count) 
		= Ok ifFalse: [GdiplusError signal: 'GdipGetPathGradientPointCount failed' with: status].
	^count asInteger!

resetTransform
	"Set the receiver's transformation matrix to the identity matrix."

	| status |
	(status := GdiplusLibrary default gdipResetPathGradientTransform: self asParameter) = Ok 
		ifFalse: [GdiplusError signal: 'GdipResetPathGradientTransform failed' with: status]!

rotateTransform: aRealPoint 
	"Rotate the receiver's transformation matrix by aRealPoint."

	self rotateTransform: aRealPoint order: nil!

rotateTransform: aRealAngle order: aMatrixOrderConstant 
	"Set the receiver's transformation matrix to the product of itself and a rotation matrix 
	defined by aRealAngle with the order of transformation specified by aMatrixOrderConstant."

	| status |
	(status := GdiplusLibrary default 
				gdipRotatePathGradientTransform: self asParameter
				angle: aRealAngle
				order: aMatrixOrderConstant) = Ok 
		ifFalse: [GdiplusError signal: 'GdipRotatePathGradientTransform failed' with: status]!

scaleTransform: aRealPoint 
	"Scale the receiver's transformation matrix by aRealPoint."

	self scaleTransform: aRealPoint order: nil!

scaleTransform: aRealPoint order: aMatrixOrderConstant 
	"Set the receiver's transformation matrix to the product of itself and a scaling matrix
	defined by aRealPoint with the order of transformation specified by aMatrixOrderConstant."

	| status |
	(status := GdiplusLibrary default 
				gdipScalePathGradientTransform: self asParameter
				sx: aRealPoint x
				sy: aRealPoint y
				order: aMatrixOrderConstant) = Ok 
		ifFalse: [GdiplusError signal: 'GdipScalePathGradientTransform failed' with: status]!

surroundColor: anARGB 
	"Set anARGB as the single color that appears on the receiver's boundary."

	self surroundColors: (Array new: self pointCount withAll: anARGB)!

surroundColors
	"Answer an Array of ARGB that are the receiver's boundary colors."

	| status count colors |
	count := DWORD new value: self surroundColorsCount.
	colors := DWORDArray new: count value.
	(status := GdiplusLibrary default
				gdipGetPathGradientSurroundColorsWithCount: self asParameter
				color: colors
				count: count) = Ok
		ifFalse: [GdiplusError signal: 'GdipGetPathGradientSurroundColorsWithCount failed' with: status].
	^colors asArray collect: [:e | ARGB fromInteger: e]!

surroundColors: colorsArray
	"Set the colors that appear on the receiver's boundaries."

	| status |
	(status := GdiplusLibrary default
				gdipSetPathGradientSurroundColorsWithCount: self asParameter
				color: (DWORDArray withAll: (colorsArray collect: [:e | e asParameter]))
				count: (DWORD new value: colorsArray size)) = Ok
		ifFalse: [GdiplusError signal: 'GdipSetPathGradientSurroundColorsWithCount failed' with: status]!

surroundColorsCount
	| status count |
	count := SDWORD new.
	(status := GdiplusLibrary default gdipGetPathGradientSurroundColorCount: self asParameter
				count: count) = Ok
		ifFalse: [GdiplusError signal: 'GdipGetPathGradientSurroundColorCount failed' with: status].
	^count value!

transform
	"Answer a GdiplusMatrix that is the receiver's transformation matrix."

	| status matrix |
	matrix := GdiplusMatrix new.
	(status := GdiplusLibrary default gdipGetPathGradientTransform: self asParameter
				matrix: matrix asParameter) = Ok 
		ifFalse: [GdiplusError signal: 'GdipGetPathGradientTransform failed' with: status].
	^matrix!

transform: aGdiplusMatrix 
	"Set aGdiplusMatrix as the transformation matrix of the receiver."

	| status |
	(status := GdiplusLibrary default gdipSetPathGradientTransform: self asParameter
				matrix: aGdiplusMatrix asParameter) = Ok 
		ifFalse: [GdiplusError signal: 'GdipSetPathGradientTransform failed' with: status]!

translateTransform: aRealPoint 
	"Translate (shift) the receiver's transformation matrix by aRealPoint."

	self translateTransform: aRealPoint order: nil!

translateTransform: aRealPoint order: aMatrixOrderConstant 
	"Set the receiver's transformation matrix to the product of itself and a translation matrix
	defined by aRealPoint with the order of transformation specified by aMatrixOrderConstant."

	| status |
	(status := GdiplusLibrary default 
				gdipTranslatePathGradientTransform: self asParameter
				dx: aRealPoint x
				dy: aRealPoint y
				order: aMatrixOrderConstant) = Ok 
		ifFalse: [GdiplusError signal: 'GdipTranslatePathGradientTransform failed' with: status]!

wrapMode
	"Answer a number that indicates if and how painting is done outside the receiver's boundary path."

	| status mode |
	mode := DWORD new.
	(status := GdiplusLibrary default gdipGetPathGradientWrapMode: self asParameter wrapMode: mode) 
		= Ok ifFalse: [GdiplusError signal: 'GdipGetPathGradientWrapMode failed' with: status].
	^mode asInteger!

wrapMode: aWrapModeConstant 
	"Set if and how painting is done outside the receiver's boundary path."

	| status |
	(status := GdiplusLibrary default gdipSetPathGradientWrapMode: self asParameter
				wrapMode: aWrapModeConstant) = Ok 
		ifFalse: [GdiplusError signal: 'GdipSetPathGradientWrapMode failed' with: status]! !
!GdiplusPathGradientBrush categoriesFor: #blendBellShape:scale:!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #blendColors!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #blendColors:positions:!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #blendColorsCount!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #blendFactors!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #blendFactors:positions:!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #blendFactorsCount!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #blendTriangularShape:scale:!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #bounds!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #centerColor!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #centerColor:!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #centerPoint!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #centerPoint:!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #focusScales!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #focusScales:!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #isGammaCorrected!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #isGammaCorrected:!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #multiplyTransform:!accessing-transformations!public! !
!GdiplusPathGradientBrush categoriesFor: #multiplyTransform:order:!accessing-transformations!public! !
!GdiplusPathGradientBrush categoriesFor: #pointCount!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #resetTransform!accessing-transformations!public! !
!GdiplusPathGradientBrush categoriesFor: #rotateTransform:!accessing-transformations!public! !
!GdiplusPathGradientBrush categoriesFor: #rotateTransform:order:!accessing-transformations!public! !
!GdiplusPathGradientBrush categoriesFor: #scaleTransform:!accessing-transformations!public! !
!GdiplusPathGradientBrush categoriesFor: #scaleTransform:order:!accessing-transformations!public! !
!GdiplusPathGradientBrush categoriesFor: #surroundColor:!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #surroundColors!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #surroundColors:!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #surroundColorsCount!accessing-properties!private! !
!GdiplusPathGradientBrush categoriesFor: #transform!accessing-transformations!public! !
!GdiplusPathGradientBrush categoriesFor: #transform:!accessing-transformations!public! !
!GdiplusPathGradientBrush categoriesFor: #translateTransform:!accessing-transformations!public! !
!GdiplusPathGradientBrush categoriesFor: #translateTransform:order:!accessing-transformations!public! !
!GdiplusPathGradientBrush categoriesFor: #wrapMode!accessing-properties!public! !
!GdiplusPathGradientBrush categoriesFor: #wrapMode:!accessing-properties!public! !

!GdiplusPathGradientBrush class methodsFor!

exampleGdipPGBlendColors
	"This example displays a triangular brush with different color and positions controlling the gradient areas.

		self exampleGdipPGBlendColors showExample
	"

	| bitmap graphics brush colors |
	bitmap := GdiplusBitmap extent: 400 @ 400.
	graphics := bitmap graphics.
	brush := GdiplusPathGradientBrush points: (Array 
						with: 100 @ 0
						with: 200 @ 200
						with: 0 @ 200)
				wrapMode: WrapModeTile.
	colors := self rgb.
	graphics
		fillRectangle: (0 @ 0 extent: 200 @ 200) brush: brush;
		drawString: 'Original' at: 0 @ 0 + 10.
	brush blendColors: colors positions: #(0 0.1 1).
	graphics
		fillRectangle: (200 @ 0 extent: 200 @ 200) brush: brush;
		drawString: 'Pos: ' , (((brush blendColors at: 2) at: 2) roundTo: 0.1) displayString
			at: 200 @ 0 + 10.
	brush blendColors: colors positions: #(0 0.5 1).
	graphics
		fillRectangle: (0 @ 200 extent: 200 @ 200) brush: brush;
		drawString: 'Pos: ' , (((brush blendColors at: 2) at: 2) roundTo: 0.1) displayString
			at: 0 @ 200 + 10.
	brush blendColors: colors positions: #(0 0.9 1).
	graphics
		fillRectangle: (200 @ 200 extent: 200 @ 200) brush: brush;
		drawString: 'Pos: ' , (((brush blendColors at: 2) at: 2) roundTo: 0.1) displayString
			at: 200 @ 200 + 10.
	^bitmap!

exampleGdipPGBlendFactors
	"This example shows the effects of setting blend factors and positions on ellipse and rectangle brushes.

		self exampleGdipPGBlendFactors showExample
	"

	| bitmap graphics path brush |
	bitmap := GdiplusBitmap extent: 600 @ 300.
	graphics := bitmap graphics.
	path := GdiplusGraphicsPath new addEllipse: (0 @ 0 corner: 200 @ 150).
	(brush := GdiplusPathGradientBrush path: path)
		wrapMode: WrapModeTile;
		centerColor: ARGB blue;
		surroundColors: (Array new: brush pointCount withAll: ARGB red).
	graphics fillRectangle: (0 @ 0 extent: 200 @ 150) brush: brush.
	brush blendFactors: #(0 0.4 0.8 1) positions: #(0 0.1 0.9 1).
	graphics fillRectangle: (200 @ 0 extent: 200 @ 150) brush: brush.
	brush blendFactors: #(0 0.1 0.5 1) positions: #(0 0.3 0.7 1).
	graphics fillRectangle: (400 @ 0 extent: 200 @ 150) brush: brush.
	path := GdiplusGraphicsPath new addRectangle: (0 @ 0 corner: 200 @ 150).
	(brush := GdiplusPathGradientBrush path: path)
		wrapMode: WrapModeTile;
		centerColor: ARGB blue;
		surroundColors: (Array with: ARGB green with: ARGB red).
	graphics fillRectangle: (0 @ 150 extent: 200 @ 150) brush: brush.
	brush blendFactors: #(0 0.4 0.8 1) positions: #(0 0.1 0.9 1).
	graphics fillRectangle: (200 @ 150 extent: 200 @ 150) brush: brush.
	brush blendFactors: #(0 0.1 0.5 1) positions: #(0 0.3 0.7 1).
	graphics fillRectangle: (400 @ 150 extent: 200 @ 150) brush: brush.
	^bitmap!

exampleGdipPGBounds
	"This example creates a path gradient brush from a polygon defined by 4 points and gets the
	bounding rectangle of that polygon, i.e., the smallest rectangle that the polygon fits in.  It then
	fills the polygon with the brush and draws outlines of the polygon and the bounding rectangle.
	NB:  See comment below regarding problem with #bounds.

		self exampleGdipPGBounds showExample
	"

	| bitmap points brush bounds |
	bitmap := GdiplusBitmap extent: 250 @ 300.
	points := Array 
				with: 0 @ 0
				with: 120 @ 20
				with: 70 @ 80
				with: 30 @ 180.
	"Uncomment the next line and see how this doesn't seem to work right."
	"points := points collect: [:e | e + (20 @ 30)]."
	brush := GdiplusPathGradientBrush points: points.
	bitmap graphics translateTransform: 20 @ 30.
	bounds := brush bounds.
	(bitmap graphics)
		fillRectangle: bounds brush: brush;
		drawRectangle: bounds pen: GdiplusPen new;
		drawPolygon: points pen: GdiplusPen red.
	"	fillPolygon: points brush: brush.	"
	^bitmap!

exampleGdipPGCenterColor
	"This example creates a GdiplusPathGradientBrush from a path and sets its center color.

		self exampleGdipPGCenterColor showExample
	"

	| bitmap path brush |
	bitmap := GdiplusBitmap extent: 350 @ 250.
	path := GdiplusGraphicsPath new addEllipse: (10 @ 10 corner: 300 @ 200).
	brush := GdiplusPathGradientBrush path: path.
	brush centerColor: ARGB blue.
	bitmap graphics fillRectangle: (10 @ 10 corner: 300 @ 200) brush: brush.
	^bitmap!

exampleGdipPGCenterPoint
	"This example shows the effect of changing the center point.

		self exampleGdipPGCenterPoint showExample
	"

	| bitmap graphics path brush |
	bitmap := GdiplusBitmap extent: 300 @ 450.
	graphics := bitmap graphics.
	path := GdiplusGraphicsPath new addEllipse: (Point zero extent: 300 @ 150).
	(brush := GdiplusPathGradientBrush path: path)
		centerColor: ARGB blue;
		wrapMode: WrapModeTile;
		surroundColor: ARGB cyan.
	graphics fillEllipse: (0 @ 0 extent: 300 @ 150) brush: brush.
	graphics drawString: 'Center Point - center' at: 0 @ 0 + 10.
	brush centerPoint: 250 @ 75.
	graphics fillEllipse: (0 @ 150 extent: 300 @ 150) brush: brush.
	graphics drawString: 'Center Point - on right, inside ellipse' at: 0 @ 150 + 10.
	brush centerPoint: 300 @ 75.
	graphics fillEllipse: (0 @ 300 extent: 300 @ 150) brush: brush.
	graphics drawString: 'Center Point - on right, outside ellipse' at: 0 @ 300 + 10.
	^bitmap!

exampleGdipPGFocusScales
	"This example shows a triangle brush at normal size and then with focus scaled.

		self exampleGdipPGFocusScales showExample
	"

	| bitmap brush focusBrush |
	bitmap := GdiplusBitmap extent: 500 @ 250.
	brush := GdiplusPathGradientBrush points: self triangle.
	brush blendColors: (Array with: ARGB red with: ARGB blue) positions: #(0 1).
	focusBrush := brush clone focusScales: 0.2 @ 0.6.
	(bitmap graphics)
		fillRectangle: (0 @ 0 extent: 200 @ 200) brush: brush;
		drawString: 'Original' at: 0 @ 0;
		translateTransform: 250 @ 0;
		fillRectangle: (0 @ 0 extent: 200 @ 200) brush: focusBrush;
		drawString: 'Focus scales' at: 0 @ 0.
	^bitmap!

exampleGdipPGGamma
	"MSDN:  Using GDI+ >  Filling Shapes with a Gradient Brush > Applying Gamma Correction to a Gradient
	This example shows a brush based on a star-shaped path with and without gamma correction applied.

		self exampleGdipPGGamma showExample
	"

	| bitmap points path colors brush |
	bitmap := GdiplusBitmap extent: 400 @ 200.
	points := (OrderedCollection new)
				add: 75 @ 0;
				add: 100 @ 50;
				add: 150 @ 50;
				add: 112 @ 75;
				add: 150 @ 150;
				add: 75 @ 100;
				add: 0 @ 150;
				add: 37 @ 75;
				add: 0 @ 50;
				add: 50 @ 50;
				yourself.
	path := GdiplusGraphicsPath new addLines: points.
	colors := (OrderedCollection new)
				add: ARGB black;
				add: ARGB green;
				add: ARGB blue;
				add: ARGB white;
				add: ARGB black;
				add: ARGB green;
				add: ARGB blue;
				add: ARGB white;
				add: ARGB black;
				add: ARGB green;
				yourself.
	(brush := GdiplusPathGradientBrush path: path)
		centerColor: ARGB red;
		surroundColors: colors.
	bitmap graphics fillPath: path brush: brush.
	brush isGammaCorrected: true.
	(bitmap graphics)
		translateTransform: 200 @ 0;
		fillPath: path brush: brush;
		resetTransform;
		drawString: 'Original' at: 0 @ 160;
		drawString: 'Gamma corrected' at: 200 @ 160.
	^bitmap!

exampleGdipPGMultiply
	"This example shows a triangle brush at normal size, then scaled, then scaled and multiplied.

		self exampleGdipPGMultiply showExample
	"

	| bitmap graphics points matrix brush |
	bitmap := GdiplusBitmap extent: 650 @ 350.
	graphics := bitmap graphics.
	points := Array 
				with: 0 @ 0
				with: 150 @ 0
				with: 150 @ 150.
	brush := GdiplusPathGradientBrush points: points.
	graphics
		fillRectangle: (0 @ 0 extent: 200 @ 200) brush: brush;
		drawString: 'Original' at: 0 @ 40.
	matrix := GdiplusMatrix fromArray: #(1 0 0 1 150 150).
	brush scaleTransform: 3 @ 1 order: nil.
	graphics
		fillRectangle: (0 @ 0 extent: 450 @ 150) brush: brush;
		drawString: 'Scaled' at: 200 @ 0.
	brush multiplyTransform: matrix order: MatrixOrderAppend.
	graphics
		fillRectangle: (0 @ 0 extent: 600 @ 300) brush: brush;
		drawString: 'Scaled and Multiplied' at: 350 @ 150.
	^bitmap!

exampleGdipPGScale
	"This example shows a triangle brush at normal size and then scaled.

		self exampleGdipPGScale showExample
	"

	| bitmap points brush scaledBrush |
	bitmap := GdiplusBitmap extent: 650 @ 350.
	brush := GdiplusPathGradientBrush points: self triangle.
	brush centerColor: ARGB red.
	scaledBrush := brush copy scaleTransform: 3 @ 1.5.
	(bitmap graphics)
		fillRectangle: (0 @ 0 extent: 200 @ 200) brush: brush;
		drawString: 'Original' at: 0 @ 40;
		fillRectangle: (0 @ 0 extent: 600 @ 600) brush: scaledBrush;
		drawString: 'Scaled' at: 200 @ 0.
	^bitmap!

exampleGdipPGSurroundColors
	"This example creates a path gradient brush from a path, then sets its center and outer boundary colors.

		self exampleGdipPGSurroundColors showExample
	"

	| bitmap brush |
	bitmap := GdiplusBitmap extent: 400 @ 400.
	brush := GdiplusPathGradientBrush points: self triangle.
	brush wrapMode: WrapModeTile.
	brush centerColor: ARGB yellow.
	bitmap graphics fillRectangle: (0 @ 0 extent: 200 @ 200) brush: brush.
	brush surroundColor: ARGB red.
	bitmap graphics fillRectangle: (200 @ 0 extent: 200 @ 200) brush: brush.
	brush surroundColors: (Array with: ARGB red with: ARGB green).
	bitmap graphics fillRectangle: (0 @ 200 extent: 200 @ 200) brush: brush.
	brush surroundColors: self rgb.
	bitmap graphics fillRectangle: (200 @ 200 extent: 200 @ 200) brush: brush.
	^bitmap!

exampleGdipPGSurroundColors2
	"This example creates a path gradient brush from a an elliptical path, then sets its outer boundary colors.

		self exampleGdipPGSurroundColors2 showExample
	"

	| bitmap path brush |
	bitmap := GdiplusBitmap extent: 600 @ 450.
	path := GdiplusGraphicsPath new addEllipse: (0 @ 0 extent: 200 @ 150).
	(brush := GdiplusPathGradientBrush path: path)
		wrapMode: WrapModeTile;
		centerColor: ARGB yellow.
	bitmap graphics fillRectangle: (0 @ 0 extent: 200 @ 150) brush: brush.
	brush surroundColors: (Array with: ARGB red).
	bitmap graphics fillRectangle: (200 @ 0 extent: 200 @ 150) brush: brush.
	brush surroundColors: (Array with: ARGB red with: ARGB green).
	bitmap graphics fillRectangle: (400 @ 0 extent: 200 @ 150) brush: brush.
	brush surroundColors: self rgb.
	bitmap graphics fillRectangle: (0 @ 150 extent: 200 @ 150) brush: brush.
	brush surroundColors: self rgb , (Array with: ARGB cyan).
	bitmap graphics fillRectangle: (200 @ 150 extent: 200 @ 150) brush: brush.
	brush surroundColors: self rgb , (Array with: ARGB cyan with: ARGB magenta).
	bitmap graphics fillRectangle: (400 @ 150 extent: 200 @ 150) brush: brush.
	brush 
		surroundColors: self rgb , (Array 
						with: ARGB cyan
						with: ARGB magenta
						with: ARGB black).
	bitmap graphics fillRectangle: (0 @ 300 extent: 200 @ 150) brush: brush.
	brush 
		surroundColors: (Array new: 13 withAll: ARGB cyan) , (Array new: 13 withAll: ARGB magenta) 
				, (Array new: 13 withAll: ARGB yellow) , (Array new: 13 withAll: ARGB red) 
				, (Array new: 13 withAll: ARGB blue).
	bitmap graphics fillRectangle: (200 @ 300 extent: 200 @ 150) brush: brush.
	brush surroundColor: ARGB red.
	bitmap graphics fillRectangle: (400 @ 300 extent: 200 @ 150) brush: brush.
	^bitmap!

exampleGdipPGTransform
	"This example shows a triangle brush at normal size, then scaled, then scaled and multiplied.

		self exampleGdipPGTransform showExample
	"

	| bitmap graphics matrix brush |
	bitmap := GdiplusBitmap extent: 500 @ 350.
	graphics := bitmap graphics.
	brush := GdiplusPathGradientBrush points: self triangle.
	brush wrapMode: WrapModeTile.
	brush centerColor: ARGB yellow.
	brush surroundColors: self rgb.
	graphics
		fillRectangle: (0 @ 0 extent: 200 @ 200) brush: brush;
		drawString: 'Original' at: 0 @ 0.
	"Set the transformation for the brush (rotate, then translate)."
	matrix := GdiplusMatrix fromArray: #(0 1 -1 0 250 100).
	brush transform: matrix.
	graphics
		fillRectangle: (250 @ 100 extent: 200 @ 200) brush: brush;
		drawString: 'Rotated and translated' at: 250 @ 80.
	^bitmap!

exampleGdipPGTranslate
	"This example shows a triangle brush before and after translation.

		self exampleGdipPGTranslate showExample
	"

	| bitmap brush translateBrush |
	bitmap := GdiplusBitmap extent: 400 @ 300.
	brush := GdiplusPathGradientBrush points: self triangle.
	brush centerColor: ARGB blue.
	translateBrush := brush clone translateTransform: 125 @ 75.
	(bitmap graphics)
		fillRectangle: (0 @ 0 extent: 200 @ 200) brush: brush;
		drawString: 'Original' at: 0 @ 0;
		fillRectangle: (0 @ 0 extent: 400 @ 300) brush: translateBrush;
		drawString: 'Translated' at: 200 @ 75.
	^bitmap!

exampleGdipPGWrapMode
	"This example displays the effects of different WrapMode constants.

		self exampleGdipPGWrapMode showExample
	"

	| bitmap pathPoints brush points modes |
	bitmap := GdiplusBitmap extent: 600 @ 400.
	pathPoints := Array 
				with: 5 @ 5
				with: 25 @ 30
				with: 35 @ 60
				with: 10 @ 50.
	points := Array 
				with: 0 @ 0
				with: 200 @ 0
				with: 400 @ 0
				with: 0 @ 200
				with: 200 @ 200.
	"Take out 'reverse' in next line and see the effect on WrapModeClamp."
	modes := self enumsWrapMode reverse.
	self assert: [points size = modes size].
	modes with: points
		do: 
			[:assoc :point | 
			brush := GdiplusPathGradientBrush points: pathPoints wrapMode: assoc value.
			brush centerColor: ARGB red.
			(bitmap graphics)
				fillRectangle: (point + 10 extent: 180 @ 180) brush: brush;
				drawString: assoc key at: point].
	^bitmap!

examplesWorkspace
	"Private - These are examples in progress.  Evaluate each block separately (or all at once).

		self examplesWorkspace
	"

	| graphics bitmap points brush path colors rect |
	#GdiplusPathGradientBrush.

	"#blendFactors:positions:"
	graphics := (bitmap := GdiplusBitmap new) graphics.
	path := GdiplusGraphicsPath new addEllipse: (10 @ 10 corner: 300 @ 200).
	brush := GdiplusPathGradientBrush path: path.
	brush centerColor: ARGB red.
	brush surroundColor: ARGB cyan.
	brush blendFactors: #(0 0.4 0.8 1) positions: #(0 0.3 0.7 1).
	graphics fillRectangle: (10 @ 10 corner: 350 @ 350) brush: brush.
	bitmap showExample.

	"blendTriangularShape:scale:"
	graphics := (bitmap := GdiplusBitmap new) graphics.
	path := GdiplusGraphicsPath new addEllipse: (10 @ 10 corner: 300 @ 200).
	brush := GdiplusPathGradientBrush path: path.
	brush centerColor: ARGB red.
	colors := Array with: ARGB blue.
	brush surroundColors: colors.
	brush blendTriangularShape: 0.2 scale: 0.7.
	graphics fillRectangle: (10 @ 10 corner: 350 @ 350) brush: brush.
	bitmap showExample.

	"blendBellShape:scale:"
	graphics := (bitmap := GdiplusBitmap new) graphics.
	path := GdiplusGraphicsPath new addEllipse: (10 @ 10 corner: 300 @ 200).
	brush := GdiplusPathGradientBrush path: path.
	brush centerColor: ARGB red.
	colors := Array with: ARGB blue.
	brush surroundColors: colors.
	brush blendBellShape: 0.2 scale: 0.7.
	graphics fillRectangle: (10 @ 10 corner: 350 @ 350) brush: brush.
	bitmap showExample.

	"#bounds"
	graphics := (bitmap := GdiplusBitmap new) graphics.
	points := Array 
				with: 30 @ 20
				with: 150 @ 40
				with: 100 @ 100
				with: 60 @ 200.
	"	points := points collect: [:e | e - (30@20)].		"
	"	points := points collect: [:e | e + (100@100)].	"
	brush := GdiplusPathGradientBrush points: points.
	rect := brush bounds.
	graphics fillRectangle: rect brush: brush.
	graphics drawRectangle: rect pen: GdiplusPen new.
	graphics drawPolygon: points pen: GdiplusPen red.
	"	graphics fillPolygon: points brush: brush.	"
	bitmap showExample!

path: aGdiplusPath 
	"Answer an instance of the receiver with boundary aGdiplusPath."

	^self fromInitializer: (GdiplusPathGradientFromPathInitializer path: aGdiplusPath)!

points: points 
	"Answer an instance of the receiver with boundary path specified by points."

	^self points: points wrapMode: WrapModeClamp!

points: points wrapMode: aWrapModeConstant 
	"Answer an instance of the receiver with boundary path specified by points and 
	wrap mode specified by aWrapModeConstant."

	^self fromInitializer: (GdiplusPathGradientFromPointsInitializer points: points
				wrapMode: aWrapModeConstant)!

rgb
	"Private - Answer a 3-element Array containing red, green, and blue instances of ARGB."

	^Array 
		with: ARGB red
		with: ARGB green
		with: ARGB blue!

triangle
	^Array 
		with: 100 @ 0
		with: 200 @ 200
		with: 0 @ 200! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGBlendColors!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGBlendFactors!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGBounds!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGCenterColor!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGCenterPoint!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGFocusScales!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGGamma!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGMultiply!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGScale!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGSurroundColors!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGSurroundColors2!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGTransform!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGTranslate!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #exampleGdipPGWrapMode!examples!public!sunit! !
!GdiplusPathGradientBrush class categoriesFor: #examplesWorkspace!examples!private! !
!GdiplusPathGradientBrush class categoriesFor: #path:!instance creation!public! !
!GdiplusPathGradientBrush class categoriesFor: #points:!instance creation!public! !
!GdiplusPathGradientBrush class categoriesFor: #points:wrapMode:!instance creation!public! !
!GdiplusPathGradientBrush class categoriesFor: #rgb!examples!private! !
!GdiplusPathGradientBrush class categoriesFor: #triangle!examples!private! !

