//
//  TableRow.swift
//  StaticTable
//

#if os(iOS)

import Combine
import CoreCombine
import UIKit

public class TableRow {
	private let tableView: TableView
	private weak var section: TableSection!
	private var enableSubscription: AnyCancellable?

	public private(set) var name: TableString
	public private(set) var kind: RowKind
	public private(set) var options: RowOptions
	public private(set) var isEnabled = false

	internal init(tableView: TableView, section: TableSection, name: TableString, kind: RowKind, options: RowOptions) {
		self.tableView = tableView
		self.section = section
		self.name = name
		self.kind = kind
		self.options = options
	}

	public func moveUp(count: Int = 1) -> Self {
		self.section.moveUp(row: self, count: count)
		return self
	}

	public func enable() {
		self.isEnabled = true
		self.section.enable(row: self)
	}

	public func disable() {
		self.isEnabled = false
		self.section.disable(row: self)
	}

	public func enableTracking<P: Publisher>(publisher: P) where P.Output == Bool {
		self.enableSubscription = publisher
			.sink(receiveCompletion: { [weak self] _ in
				guard let self = self else { return }
				self.disable()
				self.enableSubscription = nil
			}, receiveValue: { [weak self] newValue in
				guard let self = self else { return }
				self.tableView.performBatchUpdates {
					newValue ? self.enable() : self.disable()
				}
			})
	}
}

extension TableRow {
	public enum RowKind {
		case text
		case value(TableString)
		case secretValue(() -> String)
		case button(() -> Void)
		case toggle(CBSubject<Bool>)
		case textField(TableString, CBSubject<String>)
		case secretTextField(TableString, CBSubject<String>)
		case menu(() -> UIViewController)
		case picker(CBSubject<String>, PickerValue.Type)
		case iconSubtitle(String, TableString)
		case largeIconSubtitle(String, TableString)
	}

	public struct RowOptions: OptionSet {
		public let rawValue: Int

		public static let selectable  = Self(rawValue: 1 << 0)
		public static let copyable    = Self(rawValue: 1 << 1)
		public static let destructive = Self(rawValue: 1 << 2)
		public static let highlighed  = Self(rawValue: 1 << 3)

		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}
}

public protocol PickerValue: CustomLocalizedStringConvertible {
	static var allCases: [Self] { get }

	var rawValue: String { get }
	init?(rawValue: String)
}

#endif
