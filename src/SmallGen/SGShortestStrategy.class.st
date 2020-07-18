Class {
	#name : #SGShortestStrategy,
	#superclass : #SGAbstractStrategy,
	#instVars : [
		'result',
		'candidates'
	],
	#category : #'SmallGen-Strategy'
}

{ #category : #decoration }
SGShortestStrategy >> chooseShortest [
	| dictionary |
	dictionary := Dictionary new.
	candidates
		keysDo: [ :key | 
			dictionary
				at:
					(self nameFor: key )
				put:
					((candidates at: key)
						sort:
							[ :a :b | (self findLenghForHistory: a) < (self findLenghForHistory: b) ])
						first ].
	candidates := dictionary 
]

{ #category : #'as yet unclassified' }
SGShortestStrategy >> cloneDictionary: aDictionary [
	^ STONJSON fromString: (STONJSON toString: aDictionary)
]

{ #category : #decoration }
SGShortestStrategy >> findLenghForEvent: aEvent [
	^ (aEvent at: #args_before)
		inject: 0
		into: [ :sum :item | sum + (self findLenghForHistory: item) ]
]

{ #category : #decoration }
SGShortestStrategy >> findLenghForHistory: aHistory [
	
	((aHistory at: #model) = #SGHistory) ifFalse: [^ 1].
	^ (aHistory at: #data)
		inject: 0
		into: [ :sum :item | sum + (self findLenghForEvent: item) ]
]

{ #category : #decoration }
SGShortestStrategy >> findShortestMethods [
	classesToGenerate
		do: [ :class | 
			candidates := Dictionary new.
			class methods
				do: [ :method | self processClass: class method: method ].
			self chooseShortest.
			result at: class put: candidates ]
]

{ #category : #decoration }
SGShortestStrategy >> isState: state1 equalWith: state2 [
	^ state1 =state2
]

{ #category : #decoration }
SGShortestStrategy >> minimizeCalls [
	result
		do: [ :methods | methods do: [ :kvp | self minimizeHistory: kvp value ] ].
	
]

{ #category : #decoration }
SGShortestStrategy >> minimizeEvent: aEvent [
	(aEvent at: #args_before) do: [ :item | self minimizeHistory: item ].
	(self
		isState: (aEvent at: #state_before)
		equalWith: (aEvent at: #state_after))
		ifTrue: [ aEvent at: #state_no_change put: true ]
]

{ #category : #decoration }
SGShortestStrategy >> minimizeHistory: aHistory [
	| toRemove |
	(aHistory at: #model) = #SGHistory
		ifFalse: [ ^ self ].
	(aHistory at: #data) do: [ :item | self minimizeEvent: item ].
	toRemove := (aHistory at: #data)
		select: [ :item | 
			| state_no_change important |
			state_no_change := item at: #state_no_change ifAbsent: [ false ].
			important := item at: #important ifAbsent: [ false ].
			important not & state_no_change ].
	toRemove
		do: [ :item | 
			item at: #remove put: true ]
]

{ #category : #decoration }
SGShortestStrategy >> nameFor: aMethod [
	^ aMethod asTestSelector
]

{ #category : #decoration }
SGShortestStrategy >> prepare [
	result := Dictionary new.
	self findShortestMethods.
	
	self minimizeCalls.
	^ result
]

{ #category : #decoration }
SGShortestStrategy >> processClass: class method: method [
	| obs |obs := (observations at: class name) values.
	obs
		do: [ :ob | 
			(ob at: #data)
				doWithIndex: [ :event :index | 
					(event at: #selector) = method selector
						ifTrue: [ self selectFor: method selector Observation: ob upTo: index ] ] ]
]

{ #category : #'as yet unclassified' }
SGShortestStrategy >> selectFor: method Observation: observation upTo: index [
	| ob |
	ob := self cloneDictionary: observation.
	ob at: #data put: ((ob at: #data) copyFrom: 1 to: index ).
	((ob at: #data) at: index) at: #important put: true.
	candidates at: method ifAbsentPut: OrderedCollection new.
	(candidates at: method) add: ob
]
