<?php

declare(strict_types=1);

namespace App\Controller;

use App\Service\EnvatoAPIClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class IndexController extends AbstractController
{
    #[Route('/', name: 'index')]
    public function index(): Response
    {
        return $this->json([
            'success' => true,
            'message' => 'Hello World!',
            'status' => Response::HTTP_OK,
        ]);
    }

    #[Route('/packages.json', name: 'packages')]
    public function packages(): Response
    {
        return $this->json([
            'success' => true,
            'message' => 'This should be a composer package!',
            'status' => Response::HTTP_OK,
        ]);
    }

    #[Route('/test', name: 'test')]
    public function test(EnvatoAPIClient $client): Response
    {
        return $this->json([
            'success' => true,
            'id' => $client->getUserId()
        ]);
    }
}
