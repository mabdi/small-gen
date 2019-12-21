Class {
	#name : #SGCallRecord,
	#superclass : #Object,
	#instVars : [
		'selector',
		'args',
		'isVoidReturn',
		'returnValue',
		'receiverLastState',
		'receiverCurrentState',
		'coverage'
	],
	#category : #'SmallGen-Model'
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
		receiverLastState: receiverLastState;
		receiverCurrentState: receiverCurrentState;
		coverage: coverage;
		yourself
]

{ #category : #accessing }
SGCallRecord >> coverage [
	^ coverage
]

{ #category : #accessing }
SGCallRecord >> coverage: anObject [
	coverage := anObject
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
SGCallRecord >> receiverCurrentState [
	^ receiverCurrentState
]

{ #category : #accessing }
SGCallRecord >> receiverCurrentState: anObject [
	receiverCurrentState := anObject
]

{ #category : #accessing }
SGCallRecord >> receiverLastState [
	^ receiverLastState
]

{ #category : #accessing }
SGCallRecord >> receiverLastState: anObject [
	receiverLastState := anObject
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
