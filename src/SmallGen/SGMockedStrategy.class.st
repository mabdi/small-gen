Class {
	#name : #SGMockedStrategy,
	#superclass : #SGAbstractStrategy,
	#instVars : [
		'result',
		'candidates',
		'currentSUT'
	],
	#category : #'SmallGen-Strategy'
}

{ #category : #decoration }
SGMockedStrategy >> changeHistoryToMocked: history [
	| copy events |
	copy := history copy.
	copy at: #model put: #SGMock.
	events := Dictionary new.
	(copy at: #data) do: [ :ev | events at: (ev at: #selector) put: ev ].
	copy at: #data put: events values.
	^ copy
]

{ #category : #decoration }
SGMockedStrategy >> changeToMocked [
	| lastCall |
	result
		do: [ :value | 
			value
				do: [ :history | 
					lastCall := (history at: #data) last.
					lastCall
						at: #args_before
						put:
							((lastCall at: #args_after)
								collect: [ :arg | self changeHistoryToMocked: arg ]).
					lastCall at: #args_after put: OrderedCollection new.
					history at: history size put: lastCall.
					self halt. ] ]
]

{ #category : #decoration }
SGMockedStrategy >> chooseShortest [
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
SGMockedStrategy >> cloneEvent: aEvent important: isImportant minimize: doMinimize isInScope: inScope [
	| clone tmp after_msgs |
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
	clone at: #result put: Dictionary new.
	(aEvent at: #result) isNotNil
		ifTrue: [ clone
				at: #result
				put: (self cloneHistory: (aEvent at: #result) minimize: doMinimize) ].
	isImportant
		ifTrue: [ 'filter args_after and add to clone' ].
	(aEvent at: #args_after)
		doWithIndex: [ :item :idx | 
			tmp := self cloneHistory: item minimize: doMinimize.
			(tmp at: #model) = #SGHistory
				ifTrue: [ after_msgs := (tmp at: #data)
						allButFirst: ((aEvent at: #args_before) at: idx) size.
					after_msgs := after_msgs select: [ :msg | (msg at: #result) isNotNil and: [(msg at: #result) size > 0] ].	
					tmp at: #data put: after_msgs ].
			(clone at: #args_after) add: tmp ].
	^ clone
]

{ #category : #decoration }
SGMockedStrategy >> cloneHistory: aHistory minimize: doMinimize [
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
SGMockedStrategy >> diffState: state_before with: state_after [
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
SGMockedStrategy >> findLenghForEvent: aEvent [
	^ (aEvent at: #args_before)
		inject: 0
		into: [ :sum :item | sum + (self findLenghForHistory: item) ]
]

{ #category : #decoration }
SGMockedStrategy >> findLenghForHistory: aHistory [
	
	((aHistory at: #model) = #SGHistory) ifFalse: [^ 1].
	^ (aHistory at: #data)
		inject: 0
		into: [ :sum :item | sum + (self findLenghForEvent: item) ]
]

{ #category : #decoration }
SGMockedStrategy >> findShortestMethods [
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
SGMockedStrategy >> isState: state1 equalWith: state2 [
	^ state1 =state2
]

{ #category : #decoration }
SGMockedStrategy >> nameFor: aMethod [
	^ aMethod asTestSelector
]

{ #category : #decoration }
SGMockedStrategy >> prepare [
	result := Dictionary new.
	self findShortestMethods.
	self changeToMocked.
	^ result
]

{ #category : #decoration }
SGMockedStrategy >> processClass: class method: method [
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
SGMockedStrategy >> selectFor: method Observation: observation upTo: index [
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
						minimize: false
						isInScope: (observation at: #type) = currentSUT name)
						ifNotNil: [ :obj | (ob at: #data) add: obj ] ] ].
	candidates at: method ifAbsentPut: OrderedCollection new.
	(candidates at: method) add: ob
]
