//
//  TableSection.swift
//  StaticTable
//

#if os(iOS)

import UIKit

public class TableSection {
	private let tableView: TableView
	private weak var data: TableData!
	private var allRows = [TableRow]()
	private var visibleRows = [TableRow]()

	public var header: TableString
	public var footer: TableString

	public var isEnabled: Bool { !self.visibleRows.isEmpty }

	public var numberOfRows: Int { self.visibleRows.count }

	public subscript(index: Int) -> TableRow {
		self.visibleRows[index]
	}

	internal init(tableView: TableView, data: TableData, header: TableString, footer: TableString) {
		self.tableView = tableView
		self.data = data
		self.header = header
		self.footer = footer
	}

	public func clear() {
		self.allRows = []
		self.visibleRows = []
		self.data.disable(section: self)
	}

	public func createRow(named name: TableString, kind: TableRow.RowKind, options: TableRow.RowOptions = []) -> TableRow {
		let row = TableRow(tableView: self.tableView, section: self, name: name, kind: kind, options: options)
		self.allRows.append(row)
		return row
	}

	internal func moveUp(row: TableRow, count: Int = 1) {
		guard let oldIndex = self.allRows.firstIndex(where: { $0 === row }) else { return }
		guard oldIndex >= count else { return }
		self.allRows.swapAt(oldIndex, oldIndex - count)

		// TODO: This is slow
		let oldVisible = self.visibleRows
		self.visibleRows = self.allRows.filter { $0.isEnabled }
		let diff = self.visibleRows.difference(from: oldVisible, by: ===)
		self.data.enable(section: self)
		self.processUpdates(diff: diff)
	}

	internal func enable(row: TableRow) {
		// TODO: This is slow
		let oldVisible = self.visibleRows
		self.visibleRows = self.allRows.filter { $0.isEnabled }
		let diff = self.visibleRows.difference(from: oldVisible, by: ===)
		self.data.enable(section: self)
		self.processUpdates(diff: diff)
	}

	internal func disable(row: TableRow) {
		// TODO: This is slow
		let oldVisible = self.visibleRows
		self.visibleRows = self.allRows.filter { $0.isEnabled }
		let diff = self.visibleRows.difference(from: oldVisible, by: ===)
		self.data.disable(section: self)
		self.processUpdates(diff: diff)
	}

	internal func processUpdates(diff: CollectionDifference<TableRow>) {
		guard let section = self.data.sectionNumber(for: self) else { return }
		for change in diff {
			switch change {
				case .insert(let row, _, _):
					self.tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .automatic)
				case .remove(let row, _, _):
					self.tableView.deleteRows(at: [IndexPath(row: row, section: section)], with: .automatic)
			}
		}
	}
}

#endif
