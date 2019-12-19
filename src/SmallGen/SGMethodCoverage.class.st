Class {
	#name : #SGMethodCoverage,
	#superclass : #Object,
	#instVars : [
		'generatedInputs',
		'targets',
		'coverageData',
		'config'
	],
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGMethodCoverage class >> initWith: config [
	^ self new with: config
]

{ #category : #'as yet unclassified' }
SGMethodCoverage >> compileStatementsToBlock: ast [
	| src |
	src := (RBBlockNode body: ast) formattedCode.
	^ Smalltalk compiler source: src; evaluate.
]

{ #category : #'as yet unclassified' }
SGMethodCoverage >> coverageFrom: aBlock target: aTargetClass [
	| executed methods link |
	" Code from: DTTestCoverage>>#runForConfiguration: "
	methods := aTargetClass methods.
	link := MetaLink new
		selector: #tagExecuted;
		metaObject: #node.
	[ methods do: [ :meth | meth ast link: link ].
	aBlock
		ensure: [ link uninstall ] ] valueUnpreemptively.
	executed := methods select: [ :each | each ast hasBeenExecuted ].
	methods
		do: [ :each | each ast removeProperty: #tagExecuted ifAbsent: [  ] ].
	^ executed collect: #selector
]

{ #category : #'as yet unclassified' }
SGMethodCoverage >> generateCoverageData [
	generatedInputs
		keysDo: [ :target | 
			coverageData at: target put: OrderedCollection new.
			(generatedInputs at: target)
				do:  [ :ast | 
					| block unCovered |
					block := self compileStatementsToBlock: ast.
					unCovered := self coverageFrom: block target: target.
					(coverageData at: target) add: unCovered ]
				displayingProgress: 'Coverage for: ', target name ]
]

{ #category : #'as yet unclassified' }
SGMethodCoverage >> generateCoverageFor: listOftargets byRunning: listOfGeneratedInputs [
	generatedInputs := listOfGeneratedInputs.
	targets := listOftargets.
	coverageData:=Dictionary new.
	self generateCoverageData.
	^ coverageData.
]

{ #category : #'instance creation' }
SGMethodCoverage >> with: aConfig [
	self initialize.
	config := aConfig
]
