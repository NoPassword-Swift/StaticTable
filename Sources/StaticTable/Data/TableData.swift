//
//  TableData.swift
//  NoPassword.iOS
//

#if os(iOS)

import UIKit

public struct TableData {
	public var count: Int {
		self.sections.count
	}

	private var sections = [TableSection]()

	public init() {}

	public subscript(index: Int) -> TableSection {
		self.sections[index]
	}

	public subscript(indexPath: IndexPath) -> TableRow {
		self.sections[indexPath.section][indexPath.row]
	}

	public mutating func add(section: TableSection) {
		if section.count > 0 {
			self.sections.append(section)
		}
	}

	public mutating func remove(at index: Int) {
		self.sections.remove(at: index)
	}
}

#endif
