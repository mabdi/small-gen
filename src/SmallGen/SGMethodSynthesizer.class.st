Class {
	#name : #SGMethodSynthesizer,
	#superclass : #Object,
	#instVars : [
		'config',
		'observations',
		'captureTargets',
		'targetClasses',
		'generatedInputs',
		'methodNumber',
		'variableSequece',
		'generateAsserts',
		'generateExtraTemps'
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
		at: (anObservation at: #type)
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
	^ args collect: [ :arg | self genNodeFor: arg ]
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genAssertEqual: expression To: value [
	^ RBMessageNode
		receiver: (RBVariableNode named: 'self')
		selector: #assert:equals:
		arguments:
			{expression.
			value}
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genAssertExpected: expected actual: actual from: resultObj [
	| last_event statements |
	
	statements := OrderedCollection new.
	statements
		add:
			(self
				genAssertEqual: (self genCall: #class on: actual WithArgs: {})
				To: (self genCall: #class on: expected WithArgs: {})).
	last_event := (resultObj at: #data) last.
	last_event ifNil: [ ^ statements ].
	(last_event at: #state_after)
		keysAndValuesDo: [ :k :v | 
			statements
				add:
					(self
						genAssertEqual: (self genCall: k on: actual WithArgs: {})
						To: (self genCall: k on: expected WithArgs: {})) ].
	^ statements
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genAssertionResult: observation receiver: aName alreadyGenerated: oldStatements [
	| statements model expected |
	statements := OrderedCollection new.
	model := (observation at: #result)
		at: #model
		ifAbsent: [ ^ statements ].
	model = #SGPrimitive
		ifTrue: [ statements
				add:
					(self
						genAssertEqual: (RBVariableNode named: aName)
						To: (RBLiteralValueNode value: ((observation at: #result) at: #data))) ].
	({#SGCompound . #SGCompoundDictionary} includes: model)
		ifTrue: [ statements
				add:
					(self
						genAssertEqual: (self genCall: #size on: aName WithArgs: {})
						To: (RBLiteralValueNode value: ((observation at: #result) at: #data) size)).
			statements
				add:
					(self
						genAssertEqual: (self genCall: #class on: aName WithArgs: {})
						To: (RBVariableNode named: ((observation at: #result) at: #type))) ].
	model = #SGHistory
		ifTrue: [ 
			expected:= self nameForVariableSequential.
			statements
				addAll:
					(self
						genStatementForHistory: (observation at: #result)
						name: expected 
						alreadyGenerated: oldStatements , statements).
				self genAssertExpected: expected actual: aName from: (observation at: #result). ].
	model = #SGSkipped
		ifTrue: [ statements
				add:
					(self
						genAssertEqual: (self genCall: #class on: aName WithArgs: {})
						To: (RBLiteralValueNode value: ((observation at: #result) at: #type))) ].
	model = #SGClassPrimitive
		ifTrue: [ statements
				add:
					(self
						genAssertEqual: (RBVariableNode named: aName)
						To: (RBLiteralValueNode value: ((observation at: #result) at: #data))) ].
	^ statements
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genAssertionState: observation receiver: aName alreadyGenerated: oldStatements [
	| statements |
	statements := OrderedCollection new.
	(observation at: #state_after) keysAndValuesDo: [ :k :v | statements add:  (self genAssertEqual: (self genCall: k on: aName WithArgs: {  }) To: (RBLiteralValueNode value: v)) ].
	^ statements
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genAssgnmentFor: aNode to: aName [
	^ RBAssignmentNode  variable: (RBVariableNode named: aName) value: aNode	
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genBlockClosureNodeFrom: observation [
	^  (observation at: #data)
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
SGMethodSynthesizer >> genCallNew: aClassName [
	^ RBMessageNode receiver: (RBVariableNode named: aClassName) selector: 'new'
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genClassNameNodeFrom: arg [
	^ RBVariableNode named: (arg at: #data)
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genFuelFromStringNodeFrom: aString name: aName [
	^ self
		genAssgnmentFor:
			(RBMessageNode
				receiver: (RBVariableNode named: #FLMaterializer)
				selector: #materializeFromByteArray:
				arguments: { RBMessageNode receiver: (RBLiteralValueNode value: aString) selector: #base64Decoded }) 
		to: aName
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genLiteralArgNodeFrom: arg [
	^ RBLiteralNode 
		value: (arg at: #data)
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genNodeFor: observation [
	| b |
	b:= {(#SGHistory -> [ :o | self genVariableArgNodeFrom: o ]).
	(#SGPrimitive -> [ :o | self genLiteralArgNodeFrom: o ]).
	(#SGCompoundDictionary -> [ :o | self genVariableArgNodeFrom: o ]).
	(#SGCompound -> [ :o | self genVariableArgNodeFrom: o ]).
	(#SGSkipped -> [:o | self genSkippedNodeFrom: o]).
	(#SGBlockClosure -> [:o | self genBlockClosureNodeFrom: o]).
	(#SGMock -> [:o | RBVariableNode
		named: (self nameForVariableMock: (o at: #type)) ]).
	(#SGClassPrimitive -> [ :o | self genClassNameNodeFrom: o ])}
		asDictionary at: (observation at: #model).
	^ b value: observation 
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
SGMethodSynthesizer >> genSkippedNodeFrom: observation [
	^ self genCallNew: (observation at: #type)
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genStatementForCompound: observation name: aName alreadyGenerated: oldStatements [
	| statements b |
	
	statements := OrderedCollection new.
	"build non primitive items"
	(observation at: #data)
		do: [ :anArg | 
			(anArg at: #model) = #SGHistory
				ifTrue: [ statements
						addAll:
							(self
								genStatementForHistory: anArg
								name: (self nameForVariableByUniqueId: (anArg at: #uuid))
								alreadyGenerated: oldStatements , statements) ].
			(anArg at: #model) = #SGCompound
				ifTrue: [ statements
						addAll:
							(self
								genStatementForCompound: anArg
								name: (self nameForVariableByUniqueId: (anArg at: #uuid))
								alreadyGenerated: oldStatements , statements) ] ].
	"build an  Ordered collection"
	statements
		add:
			(self
				genAssgnmentFor: (self genCallNew: (observation at: #type))
				to: aName).
	b := {(#OrderedCollection
		-> [ :x | 
			self
				genStatementForOrderedCollection: observation
				name: aName
				alreadyGenerated: oldStatements ]).
	(#Set -> [ :x | self genStatementForSet: observation name: aName
				alreadyGenerated: oldStatements ]).
	(#Dictionary -> [ :x | self genStatementForDictionary: observation name: aName
				alreadyGenerated: oldStatements ])}
		asDictionary at: (observation at: #type).
	statements addAll: (b value: observation).
	^ statements
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genStatementForDictionary: observation name: aName alreadyGenerated: oldStatements [
	| statements |
	self assert: (observation at: #type) = #Dictionary.
	statements := OrderedCollection new.
	(observation at: #data)
		associationsDo: [ :anArg | 
			statements
				add:
					(self
						genCall: #at:put:
						on: aName
						WithArgs:
							{anArg key smallgen_state.
							anArg value}) ].
	^ statements
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genStatementForEvent: observation receiver: aName alreadyGenerated: oldStatements [
	| statements result_var_name addAssignment tmp |
	self assert: (observation at: #model) = #SGEvent.
	statements := OrderedCollection new.
	(observation at: #remove ifAbsent: [ false ])
		ifTrue: [ ^ statements ].
	(observation at: #args_before)
		do: [ :anArg | 
			(anArg at: #model) = #SGHistory
				ifTrue: [ statements
						addAll:
							(self
								genStatementForHistory: anArg
								name: (self nameForVariableByUniqueId: (anArg at: #uuid))
								alreadyGenerated: oldStatements , statements) ].
			(anArg at: #model) = #SGMock
				ifTrue: [ statements
						addAll:
							(self
								genStatementForMock: anArg
								name: (self nameForVariableMock: (anArg at: #type))
								alreadyGenerated: oldStatements , statements) ].
			(anArg at: #model) = #SGCompound
				ifTrue: [ statements
						addAll:
							(self
								genStatementForCompound: anArg
								name: (self nameForVariableByUniqueId: (anArg at: #uuid))
								alreadyGenerated: oldStatements , statements) ] ].
	addAssignment := observation
		at: #result
		ifPresent: [ :x | 
			x
				ifNil: [ false ]
				ifNotNil: [ x at: #model ifPresent: [ true ] ifAbsent: [ false ] ] ]
		ifAbsent: [ false ].
	addAssignment
		ifTrue: [ 
			tmp := self
				genCall: (observation at: #selector)
				on: aName
				WithArgs: (observation at: #args_before).
			generateExtraTemps
				ifTrue: [ result_var_name := self nameForVariableSequential.tmp := self genAssgnmentFor: tmp to: result_var_name ].
			statements add: tmp.
			generateAsserts
				ifTrue: [ statements
						addAll:
							(self
								genAssertionResult: observation
								receiver: result_var_name
								alreadyGenerated: oldStatements) ] ]
		ifFalse: [ statements
				add:
					(self
						genCall: (observation at: #selector)
						on: aName
						WithArgs: (observation at: #args_before)) ].
	generateAsserts
		ifTrue: [ statements
				addAll:
					(self
						genAssertionState: observation
						receiver: aName
						alreadyGenerated: oldStatements) ].
	^ statements
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genStatementForHistory: observation name: aName alreadyGenerated: oldStatements [
	| statements |
	self assert: (observation at: #model) = #SGHistory.
	statements := OrderedCollection new.
	(oldStatements
		anySatisfy: [ :item | item isAssignment and: [ item variable name = aName ] ])
		ifTrue: [ ^ statements ].
	statements
		add: (self genRefToNewObject: (observation at: #type) name: aName).
	"if class not in capture list:"
	"aHistory inScope
		ifFalse: [ statements addAll: (aHistory genNotInScopeNodeBy: self name: aName) ]."
	(observation at: #data)
		do: [ :rec | 
			statements
				addAll:
					(self
						genStatementForEvent: rec
						receiver: aName
						alreadyGenerated: statements copy) ].
	^ statements
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genStatementForMock: observation name: aName alreadyGenerated: oldStatements [
	| statements tmp |
	self assert: (observation at: #model) = #SGMock.
	
	statements := OrderedCollection new.
	statements add: (self genRefToNewObject: #Mock name: aName).
	(observation at: #data)
		do: [ :item | 
			((item at: #result) at: #model) = #SGPrimitive
				ifTrue: [ tmp := RBMessageNode
	receiver:
		(RBMessageNode
			receiver:
				(RBMessageNode receiver: (RBVariableNode named: aName) selector: #stub)
			selector: (item at: #selector))
	selector: #willReturn:
	arguments: {(RBLiteralValueNode value: ((item at: #result) at: #data))}.
					
					statements add: tmp ] ].
	^ statements
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genStatementForOrderedCollection: observation name: aName alreadyGenerated: oldStatements [
	| statements  |
	self assert: (observation at: #type) = #OrderedCollection.
	statements := OrderedCollection new.
	(observation at: #data)
		do:
			[ :anArg | statements add: (self genCall: #add: on: aName WithArgs: {anArg}) ].
	^ statements
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genStatementForSet: observation name: aName alreadyGenerated: oldStatements [
	| statements |
	self assert: (observation at: #type) = #Set.
	statements := OrderedCollection new.
	(observation at: #data)
		do:
			[ :anArg | statements add: (self genCall: #add: on: aName WithArgs: {anArg}) ].
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
SGMethodSynthesizer >> genTestMethodForHistory: anObservation name: aName [
	| theMethod theSequence statements |
	
	statements := self
		genStatementForHistory: anObservation
		name: self nameForVariableObjectUnderTest
		alreadyGenerated: {}.
	theSequence := self genSequenceWith: statements.
	theMethod := self genTestMethodWith: theSequence name: aName.
	^ theMethod
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genTestMethodWith: aSequenceNode name: aName [
	^ RBMethodNode selector: aName body: aSequenceNode
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> genVariableArgNodeFrom: arg [
	^ RBVariableNode named: (self nameForVariableByUniqueId: (arg at: #uuid))
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> generateInputs [
	| anObservation inputs |
	observations
		keysDo: [ :aClass | 
			(observations at: aClass)
				keysDo: [ :aMethod | 
					anObservation := (observations at: aClass) at: aMethod.
					inputs := self
						genTestMethodForHistory: anObservation value
						name: 'test', aMethod.
					self addInputsToResult: inputs generatedFrom: anObservation ] ]
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> generateInputsFor: aListOfTargetClass withObservation: aDicOfObservation andCaptureTargets: anArray [
	targetClasses := aListOfTargetClass asSet.
	observations := aDicOfObservation.
	captureTargets := anArray.
	generateAsserts := false.
	generateExtraTemps := false.
	generatedInputs := Dictionary new.
	methodNumber := 0.
	self generateInputs.
	^ generatedInputs
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> generateTestFor: aListOfTargetClass withObservation: aDicOfObservation andCaptureTargets: anArray [
	targetClasses := aListOfTargetClass asSet.
	observations := aDicOfObservation.
	captureTargets := anArray.
	generateAsserts := true.
	generateExtraTemps := true.
	generatedInputs := Dictionary new.
	methodNumber := 0.
	self generateInputs.
	^ generatedInputs
]

{ #category : #initialization }
SGMethodSynthesizer >> initialize [
	variableSequece := 0
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> nameForVariableByUniqueId: aUniqId [
	^ 'var_', aUniqId asString
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> nameForVariableMock: mockType [
	^ 'mock_' , mockType 
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> nameForVariableObjectUnderTest [
	^ 'object'
]

{ #category : #'as yet unclassified' }
SGMethodSynthesizer >> nameForVariableSequential [
	variableSequece := variableSequece + 1.
	^ 'var_' , variableSequece asString
]

{ #category : #'instance creation' }
SGMethodSynthesizer >> with: aConfig [
	self initialize.
	config := aConfig 
]
