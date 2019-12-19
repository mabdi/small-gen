Class {
	#name : #SGInputGenerator,
	#superclass : #Object,
	#instVars : [
		'config',
		'observations',
		'targetClasses',
		'generatedInputs',
		'methodNumber'
	],
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGInputGenerator class >> initWith: config [
	^ self new with: config
]

{ #category : #adding }
SGInputGenerator >> addInputsToResult: inputs generatedFrom: anObservation [
	| list |
	list := generatedInputs
		at: anObservation theClass
		ifAbsentPut: OrderedCollection new.
		list addAll: inputs
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genATestMethodName [
	methodNumber := methodNumber+ 1.
	^ 'testMetodNumber' , methodNumber asString
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genArgNodesFrom: args [
	^ args
		collect: [ :arg | 
			arg primitive
				ifTrue: [ self genLiteralArgNodeFrom: arg ]
				ifFalse: [ self genVariableArgNodeFrom: arg ] ]
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genAssgnmentFor: aNode to: aName [
	^ RBAssignmentNode  variable: (RBVariableNode named: aName) value: aNode	
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genCall: selector onObjectUnderTestWithArgs: args [
	| argNodes |
	argNodes := self genArgNodesFrom: args.
	^ RBMessageNode
		receiver: (RBVariableNode named: self nameForVariableObjectUnderTest)
		selector: selector
		arguments: argNodes 
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genCallNew: aClass [
	^ RBMessageNode receiver: (RBVariableNode named: aClass name) selector: 'new'
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genLiteralArgNodeFrom: arg [
	^ RBLiteralNode 
		value: arg theValue
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genRefToObjectUnderTest: theClass [
	| newCall |
	newCall := self genCallNew: theClass.
	^ self genAssgnmentFor: newCall to: self nameForVariableObjectUnderTest
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genSequenceWith: anArray [
	| temporaries |
	temporaries := self genTempVariablesFrom: anArray.
	^ RBSequenceNode temporaries: temporaries statements: anArray
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genStatementForArg: anArg alreadyGenerated: oldStatements [
	^ {  }
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genStatementForRecord: aRecord alreadyGenerated: oldStatements [
	| statements |
	statements := OrderedCollection new.
	aRecord args
		do: [ :anArg | 
			statements
				addAll:
					(self
						genStatementForArg: anArg
						alreadyGenerated: oldStatements , statements) ].
	statements
		add:
			(self
				genCall: aRecord selector
				onObjectUnderTestWithArgs: aRecord args).
	^ statements
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genTempVariablesFrom: anArray [
	^ (anArray
		select: #isAssignment
		thenCollect: [ :anAssignment | RBTemporaryNode named: anAssignment variable name ]) 
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genTestMethodWith: aSequenceNode [
	^ RBMethodNode selector: self genATestMethodName body: aSequenceNode
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genVariableArgNodeFrom: arg [
	^ RBVariableNode named: (self nameForVariableByUniqueId: arg theUniqueId)
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> generateInputs [
	observations
		do: [ :anObservation | 
			| inputs |
			inputs := self generateInputsFor: anObservation.
			self addInputsToResult: inputs generatedFrom: anObservation
			 ]
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> generateInputsFor: anObservation [
	| theMethod theSequence statements |
	statements := OrderedCollection new.
	statements
		add: (self genRefToObjectUnderTest: anObservation theClass).
	anObservation records
		do: [ :rec | 
			statements
				addAll: (self genStatementForRecord: rec alreadyGenerated: statements copy) ].
	theSequence := self genSequenceWith: statements.
	theMethod := self genTestMethodWith: theSequence.
	^ theMethod
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> generateInputsFor: aListOfTargetClass withObservation: aListOfObservation [
	targetClasses := aListOfTargetClass asSet.
	observations := aListOfObservation.
	generatedInputs := Dictionary new.
	methodNumber:= 0.
	self generateInputs.
	^ generatedInputs
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> nameForVariableByUniqueId: aUniqId [
	^ 'var_', aUniqId
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> nameForVariableObjectUnderTest [
	^ 'object'
]

{ #category : #'instance creation' }
SGInputGenerator >> with: aConfig [
	self initialize.
	config := aConfig 
]
