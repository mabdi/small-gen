Class {
	#name : #SGCallHistory,
	#superclass : #Object,
	#instVars : [
		'records',
		'theClass',
		'theValue',
		'theUniqueId',
		'callStack',
		'primitive'
	],
	#category : #SmallGen
}

{ #category : #'instance creation' }
SGCallHistory class >> for: anObject [
	^ self new for: anObject; yourself 
]

{ #category : #'instance creation' }
SGCallHistory class >> forPrimitive: anObject [
	^ self new
		for: anObject;
		primitive: true;
		yourself
]

{ #category : #accessing }
SGCallHistory >> append: aRecord [
	self records add: aRecord
]

{ #category : #accessing }
SGCallHistory >> callStack [
	^ callStack
]

{ #category : #accessing }
SGCallHistory >> copy [
	| inst |
	inst := self class new
		records: (records collect: [ :r | r copy ]);
		theClass: theClass;
		theUniqueId: theUniqueId;
		yourself.
	primitive ifTrue: [ inst theValue: theValue ].
	^ inst
]

{ #category : #'instance creation' }
SGCallHistory >> for: anObject [
	self initialize.
	self theClass: anObject class.
	self theValue: anObject.
	theUniqueId := anObject basicIdentityHash
]

{ #category : #initialization }
SGCallHistory >> initialize [
	records := OrderedCollection new.
	callStack:= Stack new.
]

{ #category : #accessing }
SGCallHistory >> primitive [
	^ primitive
]

{ #category : #accessing }
SGCallHistory >> primitive: aBoolean [
	primitive:= aBoolean 
]

{ #category : #printing }
SGCallHistory >> printOn: aStream [
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
SGCallHistory >> records [
	^ records
]

{ #category : #accessing }
SGCallHistory >> records: recs [
	records := recs
]

{ #category : #accessing }
SGCallHistory >> theClass [
	^ theClass
]

{ #category : #accessing }
SGCallHistory >> theClass: anObject [
	theClass := anObject
]

{ #category : #accessing }
SGCallHistory >> theUniqueId [
	^ theUniqueId
]

{ #category : #accessing }
SGCallHistory >> theUniqueId: anId [
	theUniqueId:=anId
]

{ #category : #accessing }
SGCallHistory >> theValue [
	^ theValue
]

{ #category : #accessing }
SGCallHistory >> theValue: anObject [
	theValue := anObject
]
