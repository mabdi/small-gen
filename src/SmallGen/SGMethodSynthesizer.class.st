Class {
	#name : #SGMethodSynthesizer,
	#superclass : #Object,
	#instVars : [
		'config',
		'observations',
		'captureTargets',
		'targetClasses',
		'generatedInputs',
		'methodNumber'
	],
	#category : #'SmallGen-Synthesis'
}

{ #category : #'as yet unclassified' }
SGMethodSynthesizer class >> initWith: config [
	^ self new with: config
]

{ #category : #adding }
SGMethodSynthesizer >> addInputsToResult: inputs generatedFrom: anObservation [
	| list |
	list := generatedInputs
		at: anObservation theClass
		ifAbsentPut: OrderedCollection new.
		list addAll: inputs
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genATestMethodName [
	methodNumber := methodNumber+ 1.
	^ 'testMetodNumber' , methodNumber asString 
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genArgNodesFrom: args [
	^ args collect: [ :arg | arg genNodeBy: self ]
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genAssgnmentFor: aNode to: aName [
	^ RBAssignmentNode  variable: (RBVariableNode named: aName) value: aNode	
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genCall: selector on: receiver WithArgs: args [
	| argNodes |
	argNodes := self genArgNodesFrom: args.
	^ RBMessageNode
		receiver: (RBVariableNode named: receiver)
		selector: selector
		arguments: argNodes
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genCallNew: aClass [
	^ RBMessageNode receiver: (RBVariableNode named: aClass name) selector: 'new'
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genClassNameNodeFrom: arg [
	^ RBVariableNode named: arg theValue name
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genLiteralArgNodeFrom: arg [
	^ RBLiteralNode 
		value: arg theValue
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genRefToNewObject: theClass name: aName [
	| newCall |
	newCall := self genCallNew: theClass.
	^ self
		genAssgnmentFor: newCall
		to: aName
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genSTONFromStringNodeFrom: aString name: aName [
	^ self
		genAssgnmentFor:
			(RBMessageNode
				receiver: (RBVariableNode named: #STON)
				selector: #fromString:
				arguments: {(RBLiteralValueNode value: aString)})
		to: aName
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genSequenceWith: anArray [
	| temporaries |
	temporaries := self genTempVariablesFrom: anArray.
	^ RBSequenceNode temporaries: temporaries statements: anArray
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genStatementForHistory: aHistory name: aName alreadyGenerated: oldStatements [
	| statements |
	statements := OrderedCollection new.
	(oldStatements
		anySatisfy: [ :item | item isAssignment and: [ item variable name = aName ] ])
		ifTrue: [ ^ statements ].
	statements
		add: (self genRefToNewObject: aHistory theClass name: aName).
	"if class not in capture list:"
	(captureTargets includes: aHistory theClass)
		ifFalse: [ statements
				addAll: (self genSTONFromStringNodeFrom: aHistory theValue name: aName) ].
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
SGMethodSynthesizer >> genStatementForRecord: aRecord receiver: aName alreadyGenerated: oldStatements [
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
SGMethodSynthesizer >> genStatementsFor: anObservation [
	| statements |
	statements := self
		genStatementForHistory: anObservation
		name: self nameForVariableObjectUnderTest
		alreadyGenerated: {}.
	^ self genSequenceWith: statements
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genTempVariablesFrom: anArray [
	^ (anArray
		select: #isAssignment
		thenCollect: [ :anAssignment | RBTemporaryNode named: anAssignment variable name ]) 
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genTestMethodForHistory: anObservation [
	| theMethod theSequence statements |
	
	statements := self genStatementForHistory: anObservation name: self nameForVariableObjectUnderTest alreadyGenerated: {}.
	theSequence := self genSequenceWith: statements.
	theMethod := self genTestMethodWith: theSequence.
	^ theMethod
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genTestMethodWith: aSequenceNode [
	^ RBMethodNode selector: self genATestMethodName body: aSequenceNode
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genVariableArgNodeFrom: arg [
	^ RBVariableNode named: (self nameForVariableByUniqueId: arg theUniqueId)
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> generateInputs [
	observations
		keysDo: [ :aTarget | 
			(observations at: aTarget)
				do: [ :anObservation | 
					| inputs |
					inputs := self genTestMethodForHistory: anObservation.
					self addInputsToResult: inputs generatedFrom: anObservation ] ]
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> generateInputsFor: aListOfTargetClass withObservation: aDicOfObservation andCaptureTargets: anArray [
	targetClasses := aListOfTargetClass asSet.
	observations := aDicOfObservation.
	captureTargets := anArray.
	generatedInputs := Dictionary new.
	methodNumber:= 0.
	self generateInputs.
	^ generatedInputs
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> nameForVariableByUniqueId: aUniqId [
	^ 'var_', aUniqId asString
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> nameForVariableObjectUnderTest [
	^ 'object'
]

{ #category : #'instance creation' }
SGMethodSynthesizer >> with: aConfig [
	self initialize.
	config := aConfig 
]
