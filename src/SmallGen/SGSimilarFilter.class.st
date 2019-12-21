Class {
	#name : #SGSimilarFilter,
	#superclass : #Object,
	#instVars : [
		'config',
		'observations',
		'minimizedList'
	],
	#category : #'SmallGen-Filtering'
}

{ #category : #'as yet unclassified' }
SGSimilarFilter class >> initWith: config [
	^ self new with: config
]

{ #category : #'as yet unclassified' }
SGSimilarFilter >> calcAllRecordNumber: aHistory [
	^ aHistory records
		inject: 0
		into: [ :sum :rec | 
			sum + (rec args
				inject: 0
				into: [ :sum2 :arg | sum2 + (self calcAllRecordNumber: arg) ]) ]
]

{ #category : #'as yet unclassified' }
SGSimilarFilter >> historyToCoverageString: aHistory [
	^ ',' join: ((aHistory records reject: [ :r | r coverage isNil ])
		inject: Set new
		into: [ :s :r | 
			s
				addAll: r coverage;
				yourself ]) asArray sort
]

{ #category : #'as yet unclassified' }
SGSimilarFilter >> historyToString: aHistory [
	
	^ self historyToString: aHistory noRet: false noArg: false
]

{ #category : #'as yet unclassified' }
SGSimilarFilter >> historyToString: aHistory noRet: aBoolean1 noArg: aBoolean2 [
	^ String
		streamContents: [ :s | 
			aHistory records
				do: [ :r | 
					s nextPutAll: r selector.
					aBoolean2
						ifFalse: [ s nextPutAll: (', ' join: (r args collect: [ :a | a theValue ])) ].
					aBoolean2
						ifFalse: [ s nextPutAll: r returnValue asString  ] ] ]
]

{ #category : #'as yet unclassified' }
SGSimilarFilter >> historyToStringNoArg: aHistory [
	^ self historyToString: aHistory noRet: false noArg: true
]

{ #category : #'as yet unclassified' }
SGSimilarFilter >> historyToStringNoRet: aHistory [
	
	^ self historyToString: aHistory noRet: true noArg: false
]

{ #category : #'as yet unclassified' }
SGSimilarFilter >> historyToStringNoRetNoArg: aHistory [
	^ self historyToString: aHistory noRet: true noArg: true
]

{ #category : #'window management' }
SGSimilarFilter >> minimize [
	observations
		keysDo: [ :target | 
			(self minimize: (observations at: target) for: target) ]
]

{ #category : #'window management' }
SGSimilarFilter >> minimize: observationsList for: target [
	| dic loc |
	"dic := observationsList
		inject: Dictionary new
		into: [ :d :aHistory | 
			d
				at: (self historyToStringNoArg: aHistory) put: aHistory;
				yourself ]."
	loc := Dictionary new.
	dic := observationsList
		inject: Dictionary new
		into: [ :d :aHistory | 
			| num str |
			str := self historyToCoverageString: aHistory.
			num := self calcAllRecordNumber: aHistory.
			loc at: str ifAbsentPut: SmallInteger maxVal.
			(loc at: str) > num
				ifTrue: [ d at: str put: aHistory. loc at: str put: num ].
			d ].
	minimizedList at: target put: dic values
]

{ #category : #'as yet unclassified' }
SGSimilarFilter >> minimizerFor: observationData [
	observations := observationData.
	minimizedList := Dictionary new.
	self minimize.
	^ minimizedList
]

{ #category : #'instance creation' }
SGSimilarFilter >> with: aConfig [
	self initialize.
	config := aConfig
]
