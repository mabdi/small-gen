Class {
	#name : #SGEvent,
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
SGEvent >> args [
	^ args
]

{ #category : #accessing }
SGEvent >> args: anObject [
	args := anObject
]

{ #category : #copying }
SGEvent >> copy [
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
SGEvent >> coverage [
	^ coverage
]

{ #category : #accessing }
SGEvent >> coverage: anObject [
	coverage := anObject
]

{ #category : #accessing }
SGEvent >> isVoidReturn [
	^ isVoidReturn
]

{ #category : #accessing }
SGEvent >> isVoidReturn: anObject [
	isVoidReturn := anObject
]

{ #category : #printing }
SGEvent >> printOn: aStream [
	aStream
		nextPutAll: '[';
		nextPutAll: selector asString;
		space;
		nextPutAll: ('' join: (self args collect: #asString));
		nextPutAll: ']'
]

{ #category : #accessing }
SGEvent >> receiverCurrentState [
	^ receiverCurrentState
]

{ #category : #accessing }
SGEvent >> receiverCurrentState: anObject [
	receiverCurrentState := anObject
]

{ #category : #accessing }
SGEvent >> receiverLastState [
	^ receiverLastState
]

{ #category : #accessing }
SGEvent >> receiverLastState: anObject [
	receiverLastState := anObject
]

{ #category : #accessing }
SGEvent >> returnValue [
	^ returnValue
]

{ #category : #accessing }
SGEvent >> returnValue: anObject [
	returnValue := anObject
]

{ #category : #accessing }
SGEvent >> selector [
	^ selector
]

{ #category : #accessing }
SGEvent >> selector: anObject [
	selector := anObject
]
