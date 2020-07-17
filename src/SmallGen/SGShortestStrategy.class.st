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
SGShortestStrategy >> nameFor: aMethod [
	^ aMethod asTestSelector
]

{ #category : #decoration }
SGShortestStrategy >> prepare [
	result := Dictionary new.
	classesToGenerate
		do: [ :class | 
			candidates := Dictionary new.
			class methods
				do: [ :method | self processClass: class method: method ].
			self chooseShortest.
			
			result at: class put: candidates ].
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
	ob := observation copy.
	ob at: #data put: ((ob at: #data) copyFrom: 1 to: index).
	candidates at: method ifAbsentPut: OrderedCollection new.
	(candidates at: method) add: ob
]
