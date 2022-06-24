//
//  StaticTableController.swift
//  NoPassword.iOS
//

#if os(iOS)

import CoreCombine
import Font
import NPCombine
import NPKit
import UIKit
import UniformTypeIdentifiers

private enum CellIdentifier {
	static let Text = "TextCell"
	static let Value = "ValueCell"
	static let SecretValue = "SecretValueCell"
	static let Button = "ButtonCell"
	static let LargeIconSubtitle = "LargeIconSubtitleCell"
}

open class StaticTableController: NPTableViewController {
	public var data: TableData

	private let enableAPI: CBSubject<Bool>?
	private let breakAPI: CBSubject<Bool>?

	public init(style: UITableView.Style, data: TableData, enableAPI: CBSubject<Bool>? = nil, breakAPI: CBSubject<Bool>? = nil) {
		self.data = data
		self.enableAPI = enableAPI
		self.breakAPI = breakAPI
		super.init(style: style)

		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTap(recognizer:)))
		self.tableView.backgroundView = UIView()
		self.tableView.backgroundView?.addGestureRecognizer(tapRecognizer)
	}

	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView = StaticTableView(frame: self.tableView.frame, style: self.tableView.style)
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.dragDelegate = self

		self.tableView.register(TextTableCell.self, forCellReuseIdentifier: CellIdentifier.Text)
		self.tableView.register(ValueTableCell.self, forCellReuseIdentifier: CellIdentifier.Value)
		self.tableView.register(SecretValueTableCell.self, forCellReuseIdentifier: CellIdentifier.SecretValue)
		self.tableView.register(ButtonTableCell.self, forCellReuseIdentifier: CellIdentifier.Button)
		self.tableView.register(LargeIconSubtitleTableCell.self, forCellReuseIdentifier: CellIdentifier.LargeIconSubtitle)
	}

	// MARK: UITableViewDataSource

	public override func numberOfSections(in tableView: UITableView) -> Int {
		return self.data.count
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.data[section].count
	}

	public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.data[section].title
	}

	public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return self.data[section].footer
	}

	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = self.data[indexPath]
		switch row.kind {
			case .text:
				let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.Text, for: indexPath) as! TextTableCell
				cell.title = row.title
				return cell

			case .value(let value):
				let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.Value, for: indexPath) as! ValueTableCell
				cell.title = row.title
				cell.value = value
				return cell

			case .secretValue(let value):
				let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.SecretValue, for: indexPath) as! SecretValueTableCell
				cell.updateSettings(enableAPI: self.enableAPI, breakAPI: self.breakAPI)
				cell.title = row.title
				if row.options.contains(.copyable) && tableView.indexPathForSelectedRow == indexPath {
					cell.secret = value()
				} else {
					cell.secret = nil
				}
				return cell

			case .button(_):
				let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.Button, for: indexPath) as! ButtonTableCell
				cell.title = row.title
				cell.setDestructive(row.options.contains(.destructive))
				return cell

			case .menu(_):
				let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.Text, for: indexPath) as! TextTableCell
				cell.title = row.title
				cell.accessoryType = .disclosureIndicator
				return cell

			case .toggle(let subject):
				let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.Text, for: indexPath) as! TextTableCell
				cell.title = row.title
				cell.accessoryView = CBToggle(tracking: subject).with(translatesAutoresizingMaskIntoConstraints: true)
				return cell

			case .singleValueSheet(let subject, let type):
				let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.Text, for: indexPath) as! TextTableCell
				cell.title = row.title
				let button = CBButton(type: .system)
				button.titleLabel?.font = Font.body
				button.titleLabel?.adjustsFontForContentSizeCategory = true
				button.track(subject: subject)
				button.onTouchUpInside { button in
					let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
					for item in type.allCases {
						alert.addAction(UIAlertAction(title: item.localizedName, style: .default, handler: { _ in
							UIView.animate(withDuration: 0, delay: 0, options: .transitionCrossDissolve) {
								button.setTitle(item.localizedName, for: .normal)
								button.sizeToFit()
							}
							subject.send(item.rawValue)
						}))
					}
					alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
					self.present(alert, animated: true)
				}
				cell.accessoryView = button
				return cell

			case .largeIconSubtitle(let image, let subtitle):
				let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.LargeIconSubtitle, for: indexPath) as! LargeIconSubtitleTableCell
				cell.image = image
				cell.title = row.title
				cell.subtitle = subtitle
				return cell
		}
	}

	// MARK: UITableViewDelegate

	public override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		if indexPath != tableView.indexPathForSelectedRow {
			self.deselectRow(animated: true)
		}

		let row = self.data[indexPath]
		switch row.kind {
			case .button(_), .menu(_):
				return true
			default:
				return row.options.contains(.selectable)
		}
	}

	public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = self.data[indexPath]
		switch row.kind {
			case .secretValue(let value):
				if let cell = tableView.cellForRow(at: indexPath) as? SecretValueTableCell {
					if !cell.isSecret {
						DispatchQueue.main.async {
							tableView.performBatchUpdates {
								cell.secret = value()
								cell.setNeedsUpdateConstraints()
							}
						}
					}
				}

			case .button(let action):
				tableView.deselectRow(at: indexPath, animated: true)
				action()

			case .menu(let constructor):
				self.navigationController?.pushViewController(constructor(), animated: true)

			default:
				tableView.deselectRow(at: indexPath, animated: true)
		}
	}

	public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		let row = self.data[indexPath]
		switch row.kind {
			case .secretValue(_):
				if let cell = tableView.cellForRow(at: indexPath) as? SecretValueTableCell {
					if cell.isSecret {
						DispatchQueue.main.async {
							tableView.performBatchUpdates {
								cell.secret = nil
								cell.setNeedsUpdateConstraints()
							}
						}
					}
				}
			default: ()
		}
	}

	public override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let row = self.data[indexPath]
		if !row.options.contains(.copyable) { return nil }
		switch row.kind {
			case .text:
				return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
					let copyAction = UIAction(title: NSLocalizedString("Copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { _ in
						UIPasteboard.general.string = row.title
					}
					return UIMenu(children: [copyAction])
				}

			case .value(let value):
				return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
					let copyAction = UIAction(title: NSLocalizedString("Copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { _ in
						UIPasteboard.general.string = value
					}
					return UIMenu(children: [copyAction])
				}

			case .secretValue(let value):
				return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
					let copyAction = UIAction(title: NSLocalizedString("Copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { _ in
						UIPasteboard.general.string = value()
					}
					return UIMenu(children: [copyAction])
				}

			default:
				return nil
		}
	}

	public override func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		guard let indexPath = configuration.identifier as? IndexPath else { return nil }
		guard let cell = tableView.cellForRow(at: indexPath) as? StaticTableCell else { return nil }

		let parameters = UIPreviewParameters()
		parameters.backgroundColor = UIColor.clear
		parameters.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 10)
		return UITargetedPreview(view: cell, parameters: parameters)
	}

	// MARK: UIScrollViewDelegate

	public override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.deselectRow(animated: true)
	}

	// MARK: Background tap detection

	@objc
	private func backgroundTap(recognizer: UITapGestureRecognizer) {
		self.deselectRow(animated: true)
	}

	// MARK: Helpers

	private func deselectRow(animated: Bool) {
		let delegate = self.tableView.delegate
		let computeIndexPath = { [self] () -> IndexPath? in
			if let indexPath = self.tableView.indexPathForSelectedRow {
				if delegate?.responds(to: #selector(tableView(_:willDeselectRowAt:))) == true {
					return delegate?.tableView?(self.tableView, willDeselectRowAt: indexPath)
				}
				return indexPath
			}
			return nil
		}
		if let indexPath = computeIndexPath() {
			if animated {
				// FIXME: This is a workaround for `deselectRow(at:animated:)` not animating
				UIView.animate(withDuration: 0.33, delay: 0) {
					self.tableView.deselectRow(at: indexPath, animated: animated)
				}
			} else {
				self.tableView.deselectRow(at: indexPath, animated: animated)
			}
			self.tableView.delegate?.tableView?(self.tableView, didDeselectRowAt: indexPath)
		}
	}
}

extension StaticTableController: UITableViewDragDelegate {
	public func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		let row = self.data[indexPath]
		if !row.options.contains(.copyable) { return [] }
		switch row.kind {
			case .text:
				guard let data = row.title.data(using: .utf8) else { return [] }
				self.deselectRow(animated: true)
				let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: UTType.utf8PlainText.identifier)
				return [UIDragItem(itemProvider: itemProvider)]

			case .value(let value):
				guard let data = value.data(using: .utf8) else { return [] }
				self.deselectRow(animated: true)
				let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: UTType.utf8PlainText.identifier)
				return [UIDragItem(itemProvider: itemProvider)]

			case .secretValue(let value):
				guard let data = value().data(using: .utf8) else { return [] }
				self.deselectRow(animated: true)
				let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: UTType.utf8PlainText.identifier)
				return [UIDragItem(itemProvider: itemProvider)]

			default:
				return []
		}
	}

	public func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
		guard let cell = tableView.cellForRow(at: indexPath) as? StaticTableCell else { return nil }

		let parameters = UIDragPreviewParameters()
		parameters.backgroundColor = UIColor.clear
		parameters.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 10)
		return parameters
	}
}

#endif
