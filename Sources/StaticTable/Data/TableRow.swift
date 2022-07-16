//
//  TableRow.swift
//  StaticTable
//

#if os(iOS)

import CoreCombine
import UIKit

public protocol SheetSingleValue: CustomLocalizedStringConvertible {
	static var allCases: [Self] { get }

	var rawValue: String { get }
	init?(rawValue: String)
}

public struct TableRow {
	public enum Kind {
		case text
		case value(String)
		case secretValue(() -> String)
		case button(() -> Void)
		case menu(() -> UIViewController)
		case toggle(CBSubject<Bool>)
		case singleValueSheet(CBSubject<String>, SheetSingleValue.Type)
		case largeIconSubtitle(String, String)
	}

	public struct RowOptions: OptionSet {
		public let rawValue: Int

		public static let selectable  = Self(rawValue: 1 << 0)
		public static let copyable    = Self(rawValue: 1 << 1)
		public static let destructive = Self(rawValue: 1 << 2)

		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}

	public let title: String
	public let kind: Kind
	public let options: RowOptions

	public init(_ title: String, kind: Kind, options: RowOptions = []) {
		self.title = title
		self.kind = kind
		self.options = options
	}
}

#endif
