//go:build cortexm

package machine

import "github.com/goplus/emb/device/arm"

// CPUReset performs a hard system reset.
func CPUReset() {
	arm.SystemReset()
}
