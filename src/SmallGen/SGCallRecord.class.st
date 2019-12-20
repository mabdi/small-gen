Class {
	#name : #SGCallRecord,
	#superclass : #Object,
	#instVars : [
		'selector',
		'args',
		'isVoidReturn',
		'returnValue'
	],
	#category : #SmallGen
}

{ #category : #accessing }
SGCallRecord >> args [
	^ args
]

{ #category : #accessing }
SGCallRecord >> args: anObject [
	args := anObject
]

{ #category : #copying }
SGCallRecord >> copy [
	^ self class new
		args: (args collect: [ :arg | arg copy ]);
		selector: selector;
		isVoidReturn: isVoidReturn;
		returnValue: returnValue;
		yourself
]

{ #category : #accessing }
SGCallRecord >> isVoidReturn [
	^ isVoidReturn
]

{ #category : #accessing }
SGCallRecord >> isVoidReturn: anObject [
	isVoidReturn := anObject
]

{ #category : #printing }
SGCallRecord >> printOn: aStream [
	aStream
		nextPutAll: '[';
		nextPutAll: selector asString;
		space;
		nextPutAll: ('' join: (self args collect: #asString));
		nextPutAll: ']'
]

{ #category : #accessing }
SGCallRecord >> returnValue [
	^ returnValue
]

{ #category : #accessing }
SGCallRecord >> returnValue: anObject [
	returnValue := anObject
]

{ #category : #accessing }
SGCallRecord >> selector [
	^ selector
]

{ #category : #accessing }
SGCallRecord >> selector: anObject [
	selector := anObject
]
