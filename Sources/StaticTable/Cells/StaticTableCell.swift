//
//  StaticTableCell.swift
//  StaticTable
//

#if os(iOS)

import Combine
import UIKit

public class StaticTableCell: UITableViewCell {
	public var subscriptions = [AnyCancellable]()

	public override func prepareForReuse() {
		super.prepareForReuse()
		self.accessoryView = nil
		self.accessoryType = .none
		self.subscriptions = []
	}
}

#endif
