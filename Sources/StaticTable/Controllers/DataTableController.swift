//
//  DataTableController.swift
//  StaticTable
//

#if os(iOS)

import CoreCombine
import NPCombine
import UIKit
import UniformTypeIdentifiers

open class DataTableController: TableController {
	public private(set) lazy var data: TableData = TableData(tableView: self.tableView as! TableView)

	public var enableAPI: CBSubject<Bool>?
	public var breakAPI: CBSubject<Bool>?

	open override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.dragDelegate = self

		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTap(recognizer:)))
		self.tableView.backgroundView = UIView()
		self.tableView.backgroundView?.addGestureRecognizer(tapRecognizer)
	}

	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.deselectRow(animated: true)
	}

	open override func tableView(_ tableView: TableView, cellForRowAt indexPath: IndexPath) -> TableCell {
		let row = self.data[indexPath]
		switch row.kind {
			case .text:
				let cell = tableView.dequeueText(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
					case let .subject(subject): cell.bindTitle(to: subject)
				}
				return cell
			case let .value(value):
				let cell = tableView.dequeueValue(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
					case let .subject(subject): cell.bindTitle(to: subject)
				}
				switch value {
					case .none: cell.value = " "
					case let .string(value): cell.value = value
					case let .subject(subject): cell.bindValue(to: subject)
				}
				return cell
			case let .secretValue(secret):
				let cell = tableView.dequeueSecretValue(for: indexPath)
				cell.updateSettings(enableAPI: self.enableAPI, breakAPI: self.breakAPI)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
					case let .subject(subject): cell.bindTitle(to: subject)
				}
				if row.options.contains(.copyable) && tableView.indexPathForSelectedRow == indexPath {
					cell.secret = secret()
				} else {
					cell.secret = nil
				}
				return cell
			case .button:
				let cell = tableView.dequeueText(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
					case let .subject(subject): cell.bindTitle(to: subject)
				}
				if row.options.contains(.destructive) {
					cell.setStatus(.destructive)
				} else if row.options.contains(.highlighed) {
					cell.setStatus(.hightlighted)
				}
				cell.alignment = .center
				return cell
			case let .toggle(subject):
				let cell = tableView.dequeueToggle(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
					case let .subject(subject): cell.bindTitle(to: subject)
				}
				cell.trackToggle(to: subject)
				return cell
			case let .textField(placeholder, subject):
				let cell = tableView.dequeueTextField(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
					case let .subject(subject): cell.bindTitle(to: subject)
				}
				switch placeholder {
					case .none: cell.placeholder = nil
					case let .string(placeholder): cell.placeholder = placeholder
					case let .subject(subject): cell.placeholder = subject.value // FIXME: Binding not supported
				}
				cell.trackTextField(to: subject)
				return cell
			case let .secretTextField(placeholder, subject):
				let cell = tableView.dequeueSecretTextField(for: indexPath)
				cell.updateSettings(enableAPI: self.enableAPI, breakAPI: self.breakAPI)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
					case let .subject(subject): cell.bindTitle(to: subject)
				}
				switch placeholder {
					case .none: cell.placeholder = nil
					case let .string(placeholder): cell.placeholder = placeholder
					case let .subject(subject): cell.placeholder = subject.value // FIXME: Binding not supported
				}
				cell.isSecure = true
				cell.trackTextField(to: subject)
				return cell
			case .menu:
				let cell = tableView.dequeueText(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
					case let .subject(subject): cell.bindTitle(to: subject)
				}
				if row.options.contains(.destructive) {
					cell.setStatus(.destructive)
				} else if row.options.contains(.highlighed) {
					cell.setStatus(.hightlighted)
				}
				cell.accessoryType = .disclosureIndicator
				return cell
			case let .picker(subject, pickerType):
				let cell = tableView.dequeueButton(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
					case let .subject(subject): cell.bindTitle(to: subject)
				}
				cell.bindButtonText(to: subject.map { pickerType.init(rawValue: $0)?.localizedDescription ?? "" })
				cell.buttonAction {
					let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
					for item in pickerType.allCases {
						alert.addAction(UIAlertAction(title: item.localizedDescription, style: .default, handler: { _ in
							subject.send(item.rawValue)
						}))
					}
					alert.addAction(UIAlertAction(title: NSLocalizedString("localized.menu.cancel", comment: ""), style: .cancel))
					self.present(alert, animated: true)
				}
				return cell
			case let .iconSubtitle(icon, subtitle):
				let cell = tableView.dequeueIconSubtitle(for: indexPath)
				cell.icon = icon
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
					case let .subject(subject): cell.bindTitle(to: subject)
				}
				switch subtitle {
					case .none: cell.subtitle = " "
					case let .string(subtitle): cell.subtitle = subtitle
					case let .subject(subject): cell.bindSubtitle(to: subject)
				}
				return cell
			case let .largeIconSubtitle(icon, subtitle):
				let cell = tableView.dequeueLargeIconSubtitle(for: indexPath)
				cell.icon = icon
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
					case let .subject(subject): cell.bindTitle(to: subject)
				}
				switch subtitle {
					case .none: cell.subtitle = " "
					case let .string(subtitle): cell.subtitle = subtitle
					case let .subject(subject): cell.bindSubtitle(to: subject)
				}
				return cell
		}
	}
}

// MARK: UITableViewDataSource
extension DataTableController {
	public override func numberOfSections(in tableView: UITableView) -> Int { self.data.numberOfSections }

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { self.data[section].numberOfRows }

	public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch self.data[section].header {
			case .none: return nil
			case let .string(name): return name
			case let .subject(subject): return subject.value // FIXME: Binding not supported
		}
	}

	public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch self.data[section].footer {
			case .none: return nil
			case let .string(name): return name
			case let .subject(subject): return subject.value // FIXME: Binding not supported
		}
	}
}

// MARK: UITableViewDelegate
extension DataTableController {
	public override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		if indexPath != tableView.indexPathForSelectedRow {
			self.deselectRow(animated: true)
		}

		let row = self.data[indexPath]
		switch row.kind {
			case .button, .menu:
				return true
			case .textField:
				guard let cell = tableView.cellForRow(at: indexPath) as? TextFieldCell else { return false }
				cell.textField.becomeFirstResponder()
				return false
			case .secretTextField:
				guard let cell = tableView.cellForRow(at: indexPath) as? SecretTextFieldCell else { return false }
				cell.textField.becomeFirstResponder()
				return false
			default:
				return row.options.contains(.selectable)
		}
	}

	public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = self.data[indexPath]
		switch row.kind {
			case let .secretValue(value):
				guard let cell = tableView.cellForRow(at: indexPath) as? SecretValueCell else { return }
				if !cell.isSecret {
					DispatchQueue.main.async {
						tableView.performBatchUpdates {
							cell.secret = value()
							cell.setNeedsUpdateConstraints()
						}
					}
				}
			case let .button(action):
				tableView.deselectRow(at: indexPath, animated: true)
				action()
			case let .menu(factory):
				self.navigationController?.pushViewController(factory(), animated: true)
			default:
				tableView.deselectRow(at: indexPath, animated: true)
		}
	}

	public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		let row = self.data[indexPath]
		switch row.kind {
			case .secretValue:
				guard let cell = tableView.cellForRow(at: indexPath) as? SecretValueCell else { return }
				if cell.isSecret {
					DispatchQueue.main.async {
						tableView.performBatchUpdates {
							cell.secret = nil
							cell.setNeedsUpdateConstraints()
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
					let copyAction = UIAction(title: NSLocalizedString("localized.menu.copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { _ in
						switch row.name {
							case .none: UIPasteboard.general.string = ""
							case let .string(string): UIPasteboard.general.string = string
							case let .subject(subject): UIPasteboard.general.string = subject.value
						}
					}
					return UIMenu(children: [copyAction])
				}

			case let .value(value):
				return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
					let copyAction = UIAction(title: NSLocalizedString("localized.menu.copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { _ in
						switch value {
							case .none: UIPasteboard.general.string = ""
							case let .string(string): UIPasteboard.general.string = string
							case let .subject(subject): UIPasteboard.general.string = subject.value
						}
					}
					return UIMenu(children: [copyAction])
				}

			case let .secretValue(value):
				return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
					let copyAction = UIAction(title: NSLocalizedString("localized.menu.copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { _ in
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
		guard let cell = tableView.cellForRow(at: indexPath) as? TableCell else { return nil }

		let parameters = UIPreviewParameters()
		parameters.backgroundColor = UIColor.clear
		parameters.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 10)
		return UITargetedPreview(view: cell, parameters: parameters)
	}
}

// MARK: UIScrollViewDelegate
extension DataTableController {
	public override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.deselectRow(animated: true)
	}
}

// MARK: UITableViewDragDelegate
extension DataTableController: UITableViewDragDelegate {
	public func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		let row = self.data[indexPath]
		if !row.options.contains(.copyable) { return [] }
		switch row.kind {
			case .text:
				let data: Data
				switch row.name {
					case .none: data = Data()
					case let .string(string):
						guard let stringData = string.data(using: .utf8) else { return [] }
						data = stringData
					case let .subject(subject):
						guard let stringData = subject.value.data(using: .utf8) else { return [] }
						data = stringData
				}
				self.deselectRow(animated: true)
				let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: UTType.utf8PlainText.identifier)
				return [UIDragItem(itemProvider: itemProvider)]

			case let .value(value):
				let data: Data
				switch value {
					case .none: data = Data()
					case let .string(string):
						guard let stringData = string.data(using: .utf8) else { return [] }
						data = stringData
					case let .subject(subject):
						guard let stringData = subject.value.data(using: .utf8) else { return [] }
						data = stringData
				}
				self.deselectRow(animated: true)
				let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: UTType.utf8PlainText.identifier)
				return [UIDragItem(itemProvider: itemProvider)]

			case let .secretValue(value):
				guard let data = value().data(using: .utf8) else { return [] }
				self.deselectRow(animated: true)
				let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: UTType.utf8PlainText.identifier)
				return [UIDragItem(itemProvider: itemProvider)]

			default:
				return []
		}
	}

	public func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
		guard let cell = tableView.cellForRow(at: indexPath) as? TableCell else { return nil }
		let parameters = UIDragPreviewParameters()
		parameters.backgroundColor = UIColor.clear
		parameters.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 10)
		return parameters
	}
}

extension DataTableController {
	@objc
	private func backgroundTap(recognizer: UITapGestureRecognizer) {
		self.deselectRow(animated: true)
	}

	private func _tableView(_ tableView: UITableView, shouldDeselectRowAt indexPath: IndexPath) -> IndexPath? {
		let delegate = tableView.delegate
		if delegate?.responds(to: #selector(tableView(_:willDeselectRowAt:))) == true {
			return delegate?.tableView!(tableView, willDeselectRowAt: indexPath)
		}
		return indexPath
	}

	private func deselectRow(animated: Bool) {
		guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
		if let indexPath = self._tableView(self.tableView, shouldDeselectRowAt: indexPath) {
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

#endif
