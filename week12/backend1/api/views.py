from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

class ProtectedView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response({
            "message": f"Hello {request.user.username}, you are successfully authenticated via JWT!",
            "status": "success",
            "user": request.user.username,
            "email": request.user.email if hasattr(request.user, 'email') else ""
        })
