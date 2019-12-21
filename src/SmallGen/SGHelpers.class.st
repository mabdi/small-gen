Class {
	#name : #SGHelpers,
	#superclass : #Object,
	#category : #'SmallGen-Core'
}

{ #category : #'instance creation' }
SGHelpers >> serialize: anObject [
	"^ STON toString: anObject"

	^ (FLSerializer serializeToByteArray: anObject) base64Encoded
]

{ #category : #'instance creation' }
SGHelpers >> unserialize: aString [
	"^ STON fromString: aString"

	^ FLMaterializer materializeFromByteArray: aString base64Decoded
]
