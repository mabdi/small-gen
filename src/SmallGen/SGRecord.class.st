Class {
	#name : #SGRecord,
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
SGRecord >> args [
	^ args
]

{ #category : #accessing }
SGRecord >> args: anObject [
	args := anObject
]

{ #category : #copying }
SGRecord >> copy [
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
SGRecord >> coverage [
	^ coverage
]

{ #category : #accessing }
SGRecord >> coverage: anObject [
	coverage := anObject
]

{ #category : #accessing }
SGRecord >> isVoidReturn [
	^ isVoidReturn
]

{ #category : #accessing }
SGRecord >> isVoidReturn: anObject [
	isVoidReturn := anObject
]

{ #category : #printing }
SGRecord >> printOn: aStream [
	aStream
		nextPutAll: '[';
		nextPutAll: selector asString;
		space;
		nextPutAll: ('' join: (self args collect: #asString));
		nextPutAll: ']'
]

{ #category : #accessing }
SGRecord >> receiverCurrentState [
	^ receiverCurrentState
]

{ #category : #accessing }
SGRecord >> receiverCurrentState: anObject [
	receiverCurrentState := anObject
]

{ #category : #accessing }
SGRecord >> receiverLastState [
	^ receiverLastState
]

{ #category : #accessing }
SGRecord >> receiverLastState: anObject [
	receiverLastState := anObject
]

{ #category : #accessing }
SGRecord >> returnValue [
	^ returnValue
]

{ #category : #accessing }
SGRecord >> returnValue: anObject [
	returnValue := anObject
]

{ #category : #accessing }
SGRecord >> selector [
	^ selector
]

{ #category : #accessing }
SGRecord >> selector: anObject [
	selector := anObject
]
