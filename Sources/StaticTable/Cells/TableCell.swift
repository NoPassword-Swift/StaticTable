//
//  TableCell.swift
//  StaticTable
//

#if os(iOS)

import Combine
import UIKit

public class TableCell: UITableViewCell {
	public weak var tableView: UITableView?
	public var indexPath: IndexPath?

	public override func prepareForReuse() {
		super.prepareForReuse()
		self.accessoryView = nil
		self.accessoryType = .none
	}
}

#endif
