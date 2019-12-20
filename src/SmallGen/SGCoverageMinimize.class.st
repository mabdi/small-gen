Class {
	#name : #SGCoverageMinimize,
	#superclass : #Object,
	#instVars : [
		'config',
		'coverage',
		'minimizedList',
		'inputs'
	],
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGCoverageMinimize class >> initWith: config [
	^ self new with: config
]

{ #category : #'as yet unclassified' }
SGCoverageMinimize >> minimize [
	coverage
		keysDo: [ :target | 
			minimizedList
				at: target
				put: (self minimize: (coverage at: target) for: (inputs at: target)) ]
]

{ #category : #'as yet unclassified' }
SGCoverageMinimize >> minimize: aCoverageList for: aInputList [
	| indexesToRemove compare result |
	compare := [ :item :item2 :loc :loc2 | 
	(item allSatisfy: [ :selector | item2 includes: selector ])
		ifTrue: [ loc >= loc2 ]
		ifFalse: [ false ] ].
	indexesToRemove := OrderedCollection new.
	aCoverageList
		withIndexDo: [ :item :index | 
			aCoverageList
				withIndexDo: [ :item2 :index2 | 
					index = index2
						ifFalse: [ [ (indexesToRemove includes: index) not
								and: [ (indexesToRemove includes: index2) not ] ]
								ifTrue: [ (compare
										value: item
										value: item2
										value: (aInputList at: index) statements size
										value: (aInputList at: index2) statements size)
										ifTrue: [ indexesToRemove add: index ] ] ] ] ].
	result := OrderedCollection new.
	aInputList
		withIndexDo: [ :item :index | 
			(indexesToRemove includes: index)
				ifFalse: [ result add: item ] ].
	^ result
]

{ #category : #'as yet unclassified' }
SGCoverageMinimize >> minimizerFor: coverageData inputs: inputsList [
	coverage := coverageData.
	inputs := inputsList.
	minimizedList := Dictionary new.
	self minimize.
	^ minimizedList
]

{ #category : #'instance creation' }
SGCoverageMinimize >> with: aConfig [
	self initialize.
	config := aConfig
]
