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
	^ args collect: [ :arg | arg genNodeBy: self ]
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genAssgnmentFor: aNode to: aName [
	^ RBAssignmentNode  variable: (RBVariableNode named: aName) value: aNode	
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genCall: selector on: receiver WithArgs: args [
	| argNodes |
	argNodes := self genArgNodesFrom: args.
	^ RBMessageNode
		receiver: (RBVariableNode named: receiver)
		selector: selector
		arguments: argNodes
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genCallNew: aClass [
	^ RBMessageNode receiver: (RBVariableNode named: aClass name) selector: 'new'
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genClassNameNodeFrom: arg [
	^ RBVariableNode named: arg theValue name
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genLiteralArgNodeFrom: arg [
	^ RBLiteralNode 
		value: arg theValue
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genNodeFrom: aHistory [ 
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genRefToNewObject: theClass name: aName [
	| newCall |
	newCall := self genCallNew: theClass.
	^ self
		genAssgnmentFor: newCall
		to: aName
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genSTONFromStringNodeFrom: aString [
	^ RBMessageNode
	receiver: (RBVariableNode named: #STON)
	selector: #fromString:
	arguments: {(RBLiteralValueNode value: aString)}
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genSequenceWith: anArray [
	| temporaries |
	temporaries := self genTempVariablesFrom: anArray.
	^ RBSequenceNode temporaries: temporaries statements: anArray
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genStatementForHistory: aHistory name: aName alreadyGenerated: oldStatements [
	| statements |
	statements := OrderedCollection new.
	(oldStatements
		anySatisfy: [ :item | item isAssignment and: [ item variable name = aName ] ])
		ifTrue: [ ^ statements ].
	statements
		add: (self genRefToNewObject: aHistory theClass name: aName).
	aHistory inCaptureDomain
		ifFalse: [ statements
				addAll:
					(self
						genSTONFromStringNodeFrom: aHistory lastState ) ].
	aHistory records
		do: [ :rec | 
			statements
				addAll:
					(self
						genStatementForRecord: rec
						receiver: aName
						alreadyGenerated: statements copy) ].
	^ statements
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genStatementForRecord: aRecord receiver: aName alreadyGenerated: oldStatements [
	| statements |
	statements := OrderedCollection new.
	aRecord args
		do: [ :anArg | 
			anArg primitive
				ifFalse: [ statements
						addAll:
							(self
								genStatementForHistory: anArg
								name: (self nameForVariableByUniqueId: anArg theUniqueId)
								alreadyGenerated: oldStatements , statements) ] ].
	statements
		add:
			(self genCall: aRecord selector on: aName WithArgs: aRecord args).
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
	
	statements := self genStatementForHistory: anObservation name: self nameForVariableObjectUnderTest alreadyGenerated: {}.
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
	^ 'var_', aUniqId asString
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
