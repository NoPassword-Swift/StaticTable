//
//  StaticTableView.swift
//  NoPassword.iOS
//

#if os(iOS)

import UIKit

public class StaticTableView: UITableView {
	private var needsReloadWhenPutOnScreen = false

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

#endif
