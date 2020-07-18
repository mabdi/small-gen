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
SGHistory >> append: aRecord [
	self events add: aRecord
]

{ #category : #adding }
SGHistory >> argsDiff: argsListBefore to: argsListAfter [
	^ (argsListAfter allButFirst: argsListBefore size) asArray
]

{ #category : #accessing }
SGHistory >> callStack [
	^ callStack
]

{ #category : #converting }
SGHistory >> dictionaryRepresentation [
	^ 
			{('model' -> self class name).
			('data' -> (self events collect: #dictionaryRepresentation) asArray).
			('uuid' -> self theUniqueId).
			('type' -> self theValue class name)} asDictionary
]

{ #category : #adding }
SGHistory >> enterMethod: selector on: receiver args: args [
	| stateBefore |
	stateBefore := nil.
	self callStack
		ifEmpty: [ stateBefore := Dictionary new.
			stateBefore at: #args put: (args collect: #smallgen_state).
			"stateBefore
				at: #args_state
				put: (args collect: #smallgen_state_identity)."
			stateBefore at: #state put: receiver smallgen_state_identity ].
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
	self callStack ifNotEmpty: [ ^ false ].
	res := SGEvent new
		selector: selector;
		stateBefore: (preCallData at: #state);
		stateAfter: aReceiver smallgen_state_identity;
		argsBefore: (preCallData at: #args);
		argsAfter: (self argsDiff: (preCallData at: #args) to: (args collect: #smallgen_state)).
	aResult == aReceiver
		ifFalse: [ res result: aResult smallgen_state ].
	self append: res.
	^ true
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

{ #category : #'as yet unclassified' }
SGHistory >> state_identity [
	| vars |
	vars := (theValue class allInstVarNames
		collect: [ :v | v -> (theValue instVarNamed: v) smallgen_state_identity ]) asDictionary.
	^ vars
]

{ #category : #accessing }
SGHistory >> theUniqueId [
	^ theUniqueId
]

{ #category : #accessing }
SGHistory >> theUniqueId: anId [
	theUniqueId:=anId
]
