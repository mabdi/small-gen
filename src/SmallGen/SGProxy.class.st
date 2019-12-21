Class {
	#name : #SGProxy,
	#superclass : #ProtoObject,
	#instVars : [
		'method',
		'action'
	],
	#category : #'SmallGen-Observation'
}

{ #category : #curing }
SGProxy class >> cureClass: aClass [
	aClass methodDict values
		select: [ :x | x class = self ]
		thenDo: [ :x | self cureMethod: x ]
]

{ #category : #curing }
SGProxy class >> cureMethod: aMethod [
	| m |
	m := aMethod.
	[ m method class = self ] whileTrue: [ m := m method ].
	m uninstall
]

{ #category : #'as yet unclassified' }
SGProxy class >> on: aCompiledMethod action: action [
    "Initialize the method tracer on aCompiledMethod and returns the method tracer.
     Do not install the tracer. You need to explicitely call #install on the instance returned to install it.
    "
    ^ self basicNew initializeOn: aCompiledMethod action: action
]

{ #category : #initialization }
SGProxy >> doesNotUnderstand: aMessage [
	"Messages not understood by myself are forwarded to the CompiledMethod I hold."

	^ method perform: aMessage selector withArguments: aMessage arguments
]

{ #category : #printing }
SGProxy >> gtDisplayString [
	^ 'SGProxy'
]

{ #category : #initialization }
SGProxy >> initializeOn: aCompiledMethod action: anObject [
	aCompiledMethod class = CompiledMethod
		ifFalse: [ Error new signal: 'cannot install proxy on other object' ].
	action := anObject.
	method := aCompiledMethod
]

{ #category : #initialization }
SGProxy >> install [
	"Install myself instead of the CompiledMethod in the class holding it.
     This way, when sending a message to the CompiledMethod (to execute it for example)
     I am notified and I can remember that the method was run.
    "

	method methodClass methodDict at: method selector put: self
]

{ #category : #initialization }
SGProxy >> method [
	^ method
]

{ #category : #printing }
SGProxy >> printOn: aStream [
	aStream nextPutAll: 'SGProxy'
]

{ #category : #initialization }
SGProxy >> run: aSelector with: anArray in: aReceiver [
	"Log the fact that the method was called and execute it."

	| result |
	action preCall: aSelector with: anArray in: aReceiver.
	result := aReceiver withArgs: anArray executeMethod: method.
	action postCall: aSelector with: anArray in: aReceiver result: result.
	^ result
]

{ #category : #initialization }
SGProxy >> uninstall [
    "Put the CompiledMethod I replaced back to its place.
     After this method has been executed, I do not receive CompiledMethod's
     messages before forwarding them to it anymore.
    "
    method methodClass methodDict
         at: method selector
         put: method
]
