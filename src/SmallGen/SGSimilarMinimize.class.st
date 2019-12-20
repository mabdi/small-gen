Class {
	#name : #SGSimilarMinimize,
	#superclass : #Object,
	#instVars : [
		'config',
		'observations',
		'minimizedList',
		'inputs'
	],
	#category : #SmallGen
}

{ #category : #'window management' }
SGSimilarMinimize >> minimize [
	observations
		keysDo: [ :target | 
			minimizedList
				at: target
				put: (self minimize: (observations at: target) for: (inputs at: target)) ]
]

{ #category : #'as yet unclassified' }
SGSimilarMinimize >> minimize: aCoverageList for: aInputList [

]

{ #category : #'as yet unclassified' }
SGSimilarMinimize >> minimizerFor: observationData  inputs: inputsList [
	observations := observationData.
	inputs := inputsList.
	minimizedList := Dictionary new.
	self minimize.
	^ minimizedList
]

{ #category : #'instance creation' }
SGSimilarMinimize >> with: aConfig [
	self initialize.
	config := aConfig
]
