// Copyright (c) 2025 Proton AG
//
// This file is part of Proton Mail Bridge.
//
// Proton Mail Bridge is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail Bridge is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail Bridge.  If not, see <https://www.gnu.org/licenses/>.

// Self-update is disabled for Nix-managed installations.
//
// The upstream implementation resolves os.Executable() to a Nix store path
// and walks up three directories to find the macOS .app bundle root — which
// in a Nix installation is /nix/store. It then calls createBackup("/nix/store",
// tempDir) which recursively copies the entire Nix store (~15 GB) to $TMPDIR
// on every hourly update check, until hitting an irregular file (socket/pipe).
// The partial directory is never cleaned up, accumulating ~15 GB/hr
// (~720 GB over 48 h of uptime).
//
// Nix manages package versions via nixos-rebuild / nix-darwin rebuild.
// Self-update has no valid target in a Nix store installation.

package updater

import (
	"io"

	"github.com/Masterminds/semver/v3"
	"github.com/ProtonMail/proton-bridge/v3/internal/versioner"
)

// InstallerDarwin is a no-op installer for Nix-managed installations.
type InstallerDarwin struct{}

// NewInstaller returns a new no-op InstallerDarwin.
func NewInstaller(*versioner.Versioner) *InstallerDarwin {
	return &InstallerDarwin{}
}

// InstallUpdate is intentionally a no-op. See package comment.
func (i *InstallerDarwin) InstallUpdate(_ *semver.Version, _ io.Reader) error {
	return nil
}

// IsAlreadyInstalled always returns false.
func (i *InstallerDarwin) IsAlreadyInstalled(_ *semver.Version) bool {
	return false
}
