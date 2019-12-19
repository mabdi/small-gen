Class {
	#name : #SGHistory,
	#superclass : #Object,
	#instVars : [
		'records',
		'theClass',
		'theValue',
		'theUniqueId',
		'callStack',
		'primitive',
		'lastState',
		'inCaptureDomain'
	],
	#category : #SmallGen
}

{ #category : #'instance creation' }
SGHistory class >> for: anObject [
	^ self new for: anObject; yourself 
]

{ #category : #accessing }
SGHistory >> append: aRecord [
	self records add: aRecord
]

{ #category : #accessing }
SGHistory >> callStack [
	^ callStack
]

{ #category : #accessing }
SGHistory >> copy [
	| inst |
	inst := self class new
		records: (records collect: [ :r | r copy ]);
		theClass: theClass;
		theUniqueId: theUniqueId;
		primitive: primitive;
		inCaptureDomain: inCaptureDomain;
		yourself.
	primitive
		ifTrue: [ inst theValue: theValue ].
	^ inst
]

{ #category : #'instance creation' }
SGHistory >> for: anObject [
	self initialize.
	self theValue: anObject
]

{ #category : #'as yet unclassified' }
SGHistory >> genNodeBy: aGenerator [
	^ aGenerator genVariableArgNodeFrom: self
]

{ #category : #accessing }
SGHistory >> inCaptureDomain [
	^ inCaptureDomain
]

{ #category : #accessing }
SGHistory >> inCaptureDomain: anObject [
	inCaptureDomain := anObject
]

{ #category : #initialization }
SGHistory >> initialize [
	records := OrderedCollection new.
	callStack := Stack new.
	primitive := false.
	inCaptureDomain :=false
]

{ #category : #accessing }
SGHistory >> lastState [
	^ lastState
]

{ #category : #accessing }
SGHistory >> lastState: aString [
	lastState:=aString
]

{ #category : #accessing }
SGHistory >> primitive [
	^ primitive
]

{ #category : #accessing }
SGHistory >> primitive: aBoolean [
	primitive:= aBoolean 
]

{ #category : #printing }
SGHistory >> printOn: aStream [
	records isEmpty
		ifTrue: [ aStream
				nextPutAll: '(';
				nextPutAll: self theClass asString;
				nextPutAll: ': ';
				nextPutAll: self theValue asString;
				nextPutAll: ')' ]
		ifFalse: [ aStream
				nextPutAll: '(';
				nextPutAll: self theClass asString;
				nextPutAll: ':> ';
				nextPutAll: ('' join: (records collect: #asString));
				nextPutAll: ')' ]
]

{ #category : #accessing }
SGHistory >> records [
	^ records
]

{ #category : #accessing }
SGHistory >> records: recs [
	records := recs
]

{ #category : #accessing }
SGHistory >> theClass [
	^ theClass
]

{ #category : #accessing }
SGHistory >> theClass: anObject [
	theClass := anObject
]

{ #category : #accessing }
SGHistory >> theUniqueId [
	^ theUniqueId
]

{ #category : #accessing }
SGHistory >> theUniqueId: anId [
	theUniqueId:=anId
]

{ #category : #accessing }
SGHistory >> theValue [
	^ theValue
]

{ #category : #accessing }
SGHistory >> theValue: anObject [
	theValue := anObject.
	theUniqueId := anObject basicIdentityHash.
	self lastState: (STON toString: anObject ).
	self theClass: anObject class
]
