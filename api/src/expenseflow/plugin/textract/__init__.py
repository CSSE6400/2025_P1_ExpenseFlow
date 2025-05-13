"""Textract module for image recognition"""

from expenseflow.plugin import Plugin, PluginSettings, register_plugin

@register_plugin("textract")
class TextractPlugin(Plugin[PluginSettings]):
    pass