Class {
	#name : #SGHistory,
	#superclass : #SGState,
	#instVars : [
		'events',
		'theUniqueId',
		'callStack'
	],
	#category : #'SmallGen-Model'
}

{ #category : #accessing }
SGHistory class >> tag [
	^ 'History'
]

{ #category : #'instance creation' }
SGHistory class >> with: anObject [
	^ self new
		initializeWith: anObject;
		yourself
]

{ #category : #accessing }
SGHistory >> append: aRecord [
	self events add: aRecord
]

{ #category : #accessing }
SGHistory >> callStack [
	^ callStack
]

{ #category : #adding }
SGHistory >> enterMethod: selector args: args [
	| stateBefore |
	stateBefore := nil.
	self callStack
		ifNotEmpty: [ stateBefore := Dictionary new.
			stateBefore at: #args put: (args collect: #smallgen_state) ].
	self callStack push: selector.
	^ stateBefore
]

{ #category : #accessing }
SGHistory >> events [
	^ events
]

{ #category : #adding }
SGHistory >> exitMethod: selector on: aReceiver args: args result: aResult preCallData: preCallData [
	| res popedSelector |
	popedSelector := self callStack pop.
	popedSelector = selector
		ifFalse: [ self error: 'You shouldnt be here. something is wrong.' ].
	self callStack ifNotEmpty: [ ^ nil ].
	res := SGEvent new
		selector: selector;
		args: (preCallData at: #args).
	self append: res.
	
]

{ #category : #'as yet unclassified' }
SGHistory >> genNodeBy: aGenerator [
	^ aGenerator genVariableArgNodeFrom: self
]

{ #category : #initialization }
SGHistory >> initialize [
	events := OrderedCollection new.
	callStack := Stack new.
	theUniqueId := UUID new asString36
]

{ #category : #'instance creation' }
SGHistory >> initializeWith: anObject [
	self initialize.
	self theValue: anObject.
	
]

{ #category : #printing }
SGHistory >> printOn: aStream [
	events isEmpty
		ifTrue: [ aStream
				nextPutAll: '(';
				nextPutAll: self theClass asString;
				nextPutAll: ': ';
				nextPutAll: self theValue asString;
				nextPutAll: ')' ]
		ifFalse: [ aStream
				nextPutAll: '(';
				nextPutAll: self theClass asString;
				nextPutAll: ':> ';
				nextPutAll: ('' join: (events collect: #asString));
				nextPutAll: ')' ]
]

{ #category : #accessing }
SGHistory >> theUniqueId [
	^ theUniqueId
]

{ #category : #accessing }
SGHistory >> theUniqueId: anId [
	theUniqueId:=anId
]
