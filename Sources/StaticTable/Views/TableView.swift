//
//  TableView.swift
//  StaticTable
//

#if os(iOS)

import UIKit

public class TableView: UITableView {
	private var needsReloadWhenPutOnScreen = false
	
	public override init(frame: CGRect, style: UITableView.Style) {
		super.init(frame: frame, style: style)

		self.register(ButtonCell.self, forCellReuseIdentifier: CellIdentifier.button.rawValue)
		self.register(DetailViewCell.self, forCellReuseIdentifier: CellIdentifier.detailView.rawValue)
		self.register(IconSubtitleCell.self, forCellReuseIdentifier: CellIdentifier.iconSubtitle.rawValue)
		self.register(LargeIconSubtitleCell.self, forCellReuseIdentifier: CellIdentifier.largeIconSubtitle.rawValue)
		self.register(SecretValueCell.self, forCellReuseIdentifier: CellIdentifier.secretValue.rawValue)
		self.register(TextCell.self, forCellReuseIdentifier: CellIdentifier.text.rawValue)
		self.register(TextFieldCell.self, forCellReuseIdentifier: CellIdentifier.textField.rawValue)
		self.register(ToggleCell.self, forCellReuseIdentifier: CellIdentifier.toggle.rawValue)
		self.register(ValueCell.self, forCellReuseIdentifier: CellIdentifier.value.rawValue)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func didMoveToWindow() {
		super.didMoveToWindow()
		if self.window != nil && self.needsReloadWhenPutOnScreen {
			self.needsReloadWhenPutOnScreen = false
			self.reloadData()
		}
	}

	// MARK: Reload

	public override func reloadData() {
		if self.window == nil {
			self.needsReloadWhenPutOnScreen = true
		} else {
			super.reloadData()
		}
	}

	// MARK: Update

	public override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
		if self.window == nil {
			self.needsReloadWhenPutOnScreen = true
		} else {
			super.performBatchUpdates(updates, completion: completion)
		}
	}

	// MARK: Row

	public override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
		if self.window == nil {
			self.needsReloadWhenPutOnScreen = true
		} else {
			super.insertRows(at: indexPaths, with: animation)
		}
	}

	public override func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
		if self.window == nil {
			self.needsReloadWhenPutOnScreen = true
		} else {
			super.deleteRows(at: indexPaths, with: animation)
		}
	}

	public override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
		if self.window == nil {
			self.needsReloadWhenPutOnScreen = true
		} else {
			super.reloadRows(at: indexPaths, with: animation)
		}
	}

	public override func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
		if self.window == nil {
			self.needsReloadWhenPutOnScreen = true
		} else {
			super.moveRow(at: indexPath, to: newIndexPath)
		}
	}

	// MARK: Section

	public override func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
		if self.window == nil {
			self.needsReloadWhenPutOnScreen = true
		} else {
			super.insertSections(sections, with: animation)
		}
	}

	public override func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
		if self.window == nil {
			self.needsReloadWhenPutOnScreen = true
		} else {
			super.deleteSections(sections, with: animation)
		}
	}

	public override func reloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
		if self.window == nil {
			self.needsReloadWhenPutOnScreen = true
		} else {
			super.reloadSections(sections, with: animation)
		}
	}

	public override func moveSection(_ section: Int, toSection newSection: Int) {
		if self.window == nil {
			self.needsReloadWhenPutOnScreen = true
		} else {
			super.moveSection(section, toSection: newSection)
		}
	}

	// MARK: Deprecated

	public override func beginUpdates() {
		if self.window == nil {
			self.needsReloadWhenPutOnScreen = true
		} else {
			super.beginUpdates()
		}
	}

	public override func endUpdates() {
		if self.window == nil {
			self.needsReloadWhenPutOnScreen = true
		} else {
			super.endUpdates()
		}
	}

}

public extension TableView {
	enum CellIdentifier: String {
		case button
		case detailView
		case iconSubtitle
		case largeIconSubtitle
		case secretValue
		case text
		case textField
		case toggle
		case value
	}

	func dequeueButton(for indexPath: IndexPath) -> ButtonCell {
		self.dequeueReusableCell(withIdentifier: CellIdentifier.button.rawValue, for: indexPath) as! ButtonCell
	}

	func dequeueDetailView(for indexPath: IndexPath) -> DetailViewCell {
		self.dequeueReusableCell(withIdentifier: CellIdentifier.detailView.rawValue, for: indexPath) as! DetailViewCell
	}

	func dequeueIconSubtitle(for indexPath: IndexPath) -> IconSubtitleCell {
		self.dequeueReusableCell(withIdentifier: CellIdentifier.iconSubtitle.rawValue, for: indexPath) as! IconSubtitleCell
	}

	func dequeueLargeIconSubtitle(for indexPath: IndexPath) -> LargeIconSubtitleCell {
		self.dequeueReusableCell(withIdentifier: CellIdentifier.largeIconSubtitle.rawValue, for: indexPath) as! LargeIconSubtitleCell
	}

	func dequeueSecretValue(for indexPath: IndexPath) -> SecretValueCell {
		self.dequeueReusableCell(withIdentifier: CellIdentifier.secretValue.rawValue, for: indexPath) as! SecretValueCell
	}

	func dequeueText(for indexPath: IndexPath) -> TextCell {
		self.dequeueReusableCell(withIdentifier: CellIdentifier.text.rawValue, for: indexPath) as! TextCell
	}

	func dequeueTextField(for indexPath: IndexPath) -> TextFieldCell {
		self.dequeueReusableCell(withIdentifier: CellIdentifier.textField.rawValue, for: indexPath) as! TextFieldCell
	}

	func dequeueToggle(for indexPath: IndexPath) -> ToggleCell {
		self.dequeueReusableCell(withIdentifier: CellIdentifier.toggle.rawValue, for: indexPath) as! ToggleCell
	}

	func dequeueValue(for indexPath: IndexPath) -> ValueCell {
		self.dequeueReusableCell(withIdentifier: CellIdentifier.value.rawValue, for: indexPath) as! ValueCell
	}
}

#endif
