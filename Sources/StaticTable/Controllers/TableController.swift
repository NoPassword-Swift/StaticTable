//
//  TableController.swift
//  StaticTable
//

#if os(iOS)

import NPKit
import UIKit

open class TableController: NPTableViewController {
	public override func loadView() {
		super.loadView()
		self.tableView = TableView(frame: self.tableView.frame, style: self.tableView.style)
		self.tableView.delegate = self
		self.tableView.dataSource = self
	}

	open func tableView(_ tableView: TableView, cellForRowAt indexPath: IndexPath) -> TableCell {
		fatalError("Must be implemented by subclasses")
	}
}

// MARK: UITableViewDataSource
extension TableController {
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let tableView = tableView as? TableView else {
			return UITableViewCell(style: .default, reuseIdentifier: nil)
		}
		return self.tableView(tableView, cellForRowAt: indexPath)
	}
}

// MARK: UITableViewDelegate
extension TableController {
	public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let cell = cell as? TableCell else { return }
		cell.tableView = tableView
		cell.indexPath = indexPath
	}

//	public override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//		<#code#>
//	}

//	public override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
//		<#code#>
//	}

	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let cell = cell as? TableCell else { return }
		cell.tableView = nil
		cell.indexPath = nil
	}

//	public override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
//		<#code#>
//	}

//	public override func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
//		<#code#>
//	}

	public override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		// TODO: What should this be
		UITableView.automaticDimension
	}

	public override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		// TODO: What should this be
		UITableView.automaticDimension
	}

	public override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
		// TODO: What should this be
		UITableView.automaticDimension
	}

	public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		UITableView.automaticDimension
	}

	public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		UITableView.automaticDimension
	}

	public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		UITableView.automaticDimension
	}
}

#endif
