"
Code inspired from: ClyJumpToTestClassCommand and ClyJumpToTestMethodCommand
"
Class {
	#name : #SGBuildTestClass,
	#superclass : #Object,
	#instVars : [
		'theClass',
		'theMethods',
		'resultClass'
	],
	#category : #'SmallGen-TestClassBuilder'
}

{ #category : #adding }
SGBuildTestClass >> addCommentForClass [
	resultClass comment: 'This Class is generated by SmallGen, from ',theClass name
]

{ #category : #'as yet unclassified' }
SGBuildTestClass >> buildClass [
	| className |
	className := self testClassNameFor: theClass.
	resultClass := TestCase
		subclass: className
		instanceVariableNames: ''
		classVariableNames: ''
		package: self defaultTempPackage.
	self addCommentForClass
]

{ #category : #'as yet unclassified' }
SGBuildTestClass >> buildFor: aClass methods: listMethods [
	theClass := aClass.
	theMethods := listMethods.
	
	self removeIfExists.
	self buildClass.
	self installMethods
]

{ #category : #'as yet unclassified' }
SGBuildTestClass >> defaultTempPackage [
	^ 'SmallGenTempClasses'
]

{ #category : #'as yet unclassified' }
SGBuildTestClass >> installMethods [
	theMethods do: [ :m | resultClass  compile: m formattedCode  classified: 'test' ]
	
]

{ #category : #'as yet unclassified' }
SGBuildTestClass >> removeIfExists [
	
	(self defaultTempPackage asPackageIfAbsent: [ ^ true ]) classes
		do: [ :item | item removeFromSystem ]
		displayingProgress: 'Clear temp classes.'
]

{ #category : #'as yet unclassified' }
SGBuildTestClass >> testClassNameFor: inputClass [
	^ (inputClass name , 'Test') asSymbol
]