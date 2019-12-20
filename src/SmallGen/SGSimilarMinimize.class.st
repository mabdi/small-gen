Class {
	#name : #SGSimilarMinimize,
	#superclass : #Object,
	#instVars : [
		'config',
		'observations',
		'minimizedList'
	],
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGSimilarMinimize class >> initWith: config [
	^ self new with: config
]

{ #category : #'as yet unclassified' }
SGSimilarMinimize >> historyToString: aHistory [
	
	^ self historyToString: aHistory noRet: false noArg: false
]

{ #category : #'as yet unclassified' }
SGSimilarMinimize >> historyToString: aHistory noRet: aBoolean1 noArg: aBoolean2 [
	^ String
		streamContents: [ :s | 
			aHistory records
				do: [ :r | 
					s nextPutAll: r selector.
					aBoolean2
						ifFalse: [ s nextPutAll: (', ' join: (r args collect: [ :a | a theValue ])) ].
					aBoolean2
						ifFalse: [ s nextPutAll: r returnValue ] ] ]
]

{ #category : #'as yet unclassified' }
SGSimilarMinimize >> historyToStringNoArg: aHistory [
	^ self historyToString: aHistory noRet: false noArg: true
]

{ #category : #'as yet unclassified' }
SGSimilarMinimize >> historyToStringNoRet: aHistory [
	
	^ self historyToString: aHistory noRet: true noArg: false
]

{ #category : #'as yet unclassified' }
SGSimilarMinimize >> historyToStringNoRetNoArg: aHistory [
	^ self historyToString: aHistory noRet: true noArg: true
]

{ #category : #'window management' }
SGSimilarMinimize >> minimize [
	observations
		keysDo: [ :target | 
			(self minimize: (observations at: target) for: target) ]
]

{ #category : #'window management' }
SGSimilarMinimize >> minimize: observationsList for: target [
	| dic |
	dic := observationsList
		inject: Dictionary new
		into:
			[ :d :aHistory | d at: (self historyToStringNoArg: aHistory) put: aHistory; yourself ].
	minimizedList at: target put: dic values
]

{ #category : #'as yet unclassified' }
SGSimilarMinimize >> minimizerFor: observationData [
	observations := observationData.
	minimizedList := Dictionary new.
	self minimize.
	^ minimizedList
]

{ #category : #'instance creation' }
SGSimilarMinimize >> with: aConfig [
	self initialize.
	config := aConfig
]
