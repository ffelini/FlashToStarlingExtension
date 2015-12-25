/*
Feathers
Copyright 2012-2014 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.skins
{
import feathers.core.IFeathersControl;

/**
	 * Sets skin and style properties on a Feathers UI component.
	 */
	public interface IStyleProvider
	{
		/**
		 * Applies styles to a specific Feathers UI component, unless that
		 * component has been excluded.
		 *
		 * @see #exclude()
		 */
		function applyStyles(target:IFeathersControl):void;
	}
}