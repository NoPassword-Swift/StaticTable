//
//  TableString.swift
//  StaticTable
//

import CoreCombine

public enum TableString {
	case none
	case string(String)
	case subject(CBSubject<String>)
}
