Class {
	#name : #SGMethodCoverage,
	#superclass : #Object,
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGMethodCoverage >> coverageFrom: aBlock target: aTargetClass [
	| notExecuted methods link |
	methods := aTargetClass methods.
	link := MetaLink new
		selector: #tagExecuted;
		metaObject: #node.
	[ methods do: [ :meth | meth ast link: link ].
	[ aBlock value ]
		ensure: [ link uninstall ] ] valueUnpreemptively.
	notExecuted := methods reject: [ :each | each ast hasBeenExecuted ].
	methods
		do: [ :each | each ast removeProperty: #tagExecuted ifAbsent: [  ] ].
	^ notExecuted
]
