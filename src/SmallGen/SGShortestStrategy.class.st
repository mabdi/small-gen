Class {
	#name : #SGShortestStrategy,
	#superclass : #SGAbstractStrategy,
	#instVars : [
		'result',
		'candidates',
		'currentSUT'
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
SGShortestStrategy >> cloneEvent: aEvent important: isImportant minimize: doMinimize isInScope: inScope [
	| clone |
	doMinimize & isImportant not
		ifTrue: [ (self
				isState: (aEvent at: #state_before)
				equalWith: (aEvent at: #state_after))
				ifTrue: [ ^ nil ] ].
	clone := aEvent copy.
	clone at: #args_before put: OrderedCollection new.
	clone at: #args_after put: OrderedCollection new.
	clone at: #state_before put: Dictionary new.
	clone at: #state_after put: Dictionary new.
	inScope
		ifTrue: [ clone
				at: #state_after
				put:
					(self
						diffState: (aEvent at: #state_before)
						with: (aEvent at: #state_after)) ].
	clone at: #result put: Dictionary new.
	(aEvent at: #result) isNotNil & inScope
		ifTrue: [ clone
				at: #result
				put: (self cloneHistory: (aEvent at: #result) minimize: doMinimize) ].
	self flag: #todo.	"when you want to create mock based and assertions implemetn here."
	isImportant
		ifTrue: [ 'filter args_after and add to clone' ].
	(aEvent at: #args_before)
		do: [ :item | 
			(clone at: #args_before)
				add: (self cloneHistory: item minimize: doMinimize) ].
	^ clone
]

{ #category : #decoration }
SGShortestStrategy >> cloneHistory: aHistory minimize: doMinimize [
	| clone |
	"self halt."
	clone := aHistory copy.
	({#SGClassPrimitive. #SGPrimitive. #SGSkipped} includes: (aHistory at: #model))
		ifTrue: [ ^ clone ].
	(aHistory at: #model) = #SGCompound
		ifTrue: [ clone
				at: #data
				put:
					((aHistory at: #data)
						collect:
							[ :item | self cloneHistory: item minimize: doMinimize ]).
			^ clone ].
	(aHistory at: #model) = #SGHistory
		ifTrue: [ clone
				at: #data
				put: OrderedCollection new.
					((aHistory at: #data)
						do: [ :item | 
							(self
								cloneEvent: item
								important: false
								minimize: doMinimize
								isInScope: false) ifNotNil: [ :x | (clone at: #data) add: x ] ]).
			^ clone ].
	self halt
]

{ #category : #'as yet unclassified' }
SGShortestStrategy >> diffState: state_before with: state_after [
	| clone diff |
	clone := state_after copy.
	state_after
		keysDo: [ :k | 
			(state_after at: k) isDictionary
				ifTrue: [ diff := self
						diffState: (state_before at: k)
						with: (state_after at: k).
					diff
						ifEmpty: [ clone removeKey: k ]
						ifNotEmpty: [ clone at: k put: diff ] ]
				ifFalse: [ (state_before at: k) = (state_after at: k) ifTrue: [ clone removeKey: k ] ] ].
	^ clone
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
			currentSUT := class.
			
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
SGShortestStrategy >> nameFor: aMethod [
	^ aMethod asTestSelector
]

{ #category : #decoration }
SGShortestStrategy >> prepare [
	result := Dictionary new.
	self findShortestMethods.
	^ result
]

{ #category : #decoration }
SGShortestStrategy >> processClass: class method: method [
	| obs |
	obs := (observations at: class name ifAbsent: [ ^ self ]) values.
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
	self
		assert:
			({OrderedCollection.
			Array} includes: (observation at: #data) class).
	ob at: #data put: OrderedCollection new.
	(observation at: #data)
		doWithIndex: [ :item :idx | 
			idx <= index
				ifTrue: [ (self
						cloneEvent: item
						important: idx = index
						minimize: true
						isInScope: ((observation at: #type)  = currentSUT name))
						ifNotNil: [ :obj | (ob at: #data) add: obj ] ] ].
	candidates at: method ifAbsentPut: OrderedCollection new.
	(candidates at: method) add: ob
]
