//
//  TableSection.swift
//  StaticTable
//

#if os(iOS)

public struct TableSection {
	public let title: String?
	public let footer: String?

	public var count: Int {
		self.rows.count
	}

	private var rows = [TableRow]()

	public init(_ title: String? = nil, footer: String? = nil) {
		self.title = title
		self.footer = footer
	}

	public subscript(index: Int) -> TableRow {
		self.rows[index]
	}

	public mutating func add(row: TableRow) {
		self.rows.append(row)
	}
}

#endif
