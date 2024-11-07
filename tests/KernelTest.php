<?php

declare(strict_types=1);

namespace App\Tests;

use App\Kernel;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;

class KernelTest extends KernelTestCase
{
    public function testKernel(): void
    {
        $kernel = self::bootKernel();

        static::assertInstanceOf(Kernel::class, $kernel);
        static::assertSame('test', $kernel->getEnvironment());
    }
}
