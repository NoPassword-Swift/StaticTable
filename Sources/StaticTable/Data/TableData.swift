//
//  TableData.swift
//  StaticTable
//

#if os(iOS)

import UIKit

public class TableData {
	private let tableView: TableView
	private var allSections = [TableSection]()
	private var visibleSections = [TableSection]()

	public var numberOfSections: Int { self.visibleSections.count }

	public subscript(index: Int) -> TableSection {
		self.visibleSections[index]
	}

	public subscript(indexPath: IndexPath) -> TableRow {
		self.visibleSections[indexPath.section][indexPath.row]
	}

	internal init(tableView: TableView) {
		self.tableView = tableView
	}

	public func createSection(header: TableString = .none, footer: TableString = .none) -> TableSection {
		let section = TableSection(tableView: self.tableView, data: self, header: header, footer: footer)
		self.allSections.append(section)
		return section
	}

	internal func sectionNumber(for section: TableSection) -> Int? {
		self.visibleSections.firstIndex { $0 === section }
	}

	internal func enable(section: TableSection) {
		// TODO: This is slow
		let oldVisible = self.visibleSections
		self.visibleSections = self.allSections.filter { $0.isEnabled }
		let diff = self.visibleSections.difference(from: oldVisible, by: ===)
		self.processUpdates(diff: diff)
	}

	internal func disable(section: TableSection) {
		// TODO: This is slow
		let oldVisible = self.visibleSections
		self.visibleSections = self.allSections.filter { $0.isEnabled }
		let diff = self.visibleSections.difference(from: oldVisible, by: ===)
		self.processUpdates(diff: diff)
	}

	internal func processUpdates(diff: CollectionDifference<TableSection>) {
		for change in diff {
			switch change {
				case .insert(let section, _, _):
					self.tableView.insertSections(IndexSet(integer: section), with: .automatic)
				case .remove(let section, _, _):
					self.tableView.deleteSections(IndexSet(integer: section), with: .automatic)
			}
		}
	}
}

#endif
